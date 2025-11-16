import os
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.calibration import CalibratedClassifierCV
from lightgbm import LGBMClassifier
import optuna
import shap
from scipy import stats

RANDOM_STATE = 42
DATA_PATH = "Backend/AI/Diabetesv3/diabetes_train.csv"
ARTIFACT_DIR = "Backend/AI/Diabetesv3/artifacts"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

# Load data
df = pd.read_csv(DATA_PATH)

# Target encoding
df["Diabetes_binary"] = df["Diabetes_binary"].map({"Diabetic": 1, "Non-Diabetic": 0})

# Simplify to only available columns
df["Sex"] = df["Sex"].map({"Male": 1, "Female": 0}).fillna(0).astype(int)
df["Smoker"] = df["Smoker"].map({"Yes": 1, "No": 0}).fillna(0)
df["Fruits"] = df["Fruits"].map({"Yes": 1, "No": 0}).fillna(0)
df["Veggies"] = df["Veggies"].map({"Yes": 1, "No": 0}).fillna(0)
df["HvyAlcoholConsump"] = df["HvyAlcoholConsump"].map({"Yes": 1, "No": 0}).fillna(0)
df["DiffWalk"] = df["DiffWalk"].map({"Yes": 1, "No": 0}).fillna(0)
df["PhysActivity"] = df["PhysActivity"].map({"Yes": 1, "No": 0}).fillna(0)

# Ensure numeric health features
for c in ["MentHlth", "PhysHlth"]:
    df[c] = pd.to_numeric(df[c], errors="coerce").fillna(df[c].median())

FEATURES = [
    "Sex", "Smoker", "Fruits", "Veggies", "HvyAlcoholConsump",
    "DiffWalk", "PhysActivity", "MentHlth", "PhysHlth"
]
X = df[FEATURES].copy()
y = df["Diabetes_binary"].astype(int).values

# Scale continuous
num_feats = ["MentHlth", "PhysHlth"]
scaler = StandardScaler()
X[num_feats] = scaler.fit_transform(X[num_feats])

# CV setup
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)

# Simplified optimization
def objective(trial):
    params = {
        "n_estimators": trial.suggest_int("n_estimators", 200, 400),
        "learning_rate": trial.suggest_float("learning_rate", 0.05, 0.1),
        "num_leaves": trial.suggest_int("num_leaves", 16, 64),
        "max_depth": trial.suggest_int("max_depth", 3, 7),
        "random_state": RANDOM_STATE,
        "n_jobs": -1,
    }
    model = LGBMClassifier(**params)
    scores = cross_val_score(model, X, y, scoring="roc_auc", cv=cv, n_jobs=-1)
    return float(np.mean(scores))

study = optuna.create_study(direction="maximize")
study.optimize(objective, n_trials=10)

best_params = study.best_params
best_params.update({"random_state": RANDOM_STATE, "n_jobs": -1})

# Final model
final_model = LGBMClassifier(**best_params)
final_model.fit(X, y)
calibrated = CalibratedClassifierCV(final_model, cv=cv, method="sigmoid")
calibrated.fit(X, y)

joblib.dump({
    "scaler": scaler,
    "model": final_model,
    "calibrated": calibrated,
    "features": FEATURES,
    "best_params": best_params,
}, os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))

# SHAP
explainer = shap.TreeExplainer(final_model)
shap_values = explainer.shap_values(X, check_additivity=False)
joblib.dump({"explainer": explainer, "shap_values": shap_values}, os.path.join(ARTIFACT_DIR, "shap.joblib"))

train_probs = calibrated.predict_proba(X)[:, 1]
joblib.dump({"train_probs": train_probs}, os.path.join(ARTIFACT_DIR, "train_probs.joblib"))

def preprocess_patient(p):
    if isinstance(p, dict):
        p = pd.DataFrame([p])
    p = p.copy()
    for col in FEATURES:
        if col not in p:
            p[col] = 0
    mapping = {"Sí": 1, "No": 0, "Male": 1, "M": 1, "Female": 0, "F": 0}
    p.replace(mapping, inplace=True)
    p[num_feats] = scaler.transform(p[num_feats])
    return p[FEATURES]

def predict_risk(patient):
    p = preprocess_patient(patient)
    prob = calibrated.predict_proba(p)[:, 1][0]
    percentile = float(stats.percentileofscore(train_probs, prob, kind="weak"))
    if prob >= 0.9:
        cat = "Very high"
    elif prob >= 0.75:
        cat = "High"
    elif prob >= 0.5:
        cat = "Moderate"
    elif prob >= 0.25:
        cat = "Low"
    else:
        cat = "Very low"
    return {
        "probability": float(prob),
        "percentage": float(prob * 100),
        "percentile": percentile,
        "risk_category": cat
    }

def explain_patient(patient, top_k=6):
    p = preprocess_patient(patient)
    sv = explainer.shap_values(p, check_additivity=False)
    sv_pos = sv[1] if isinstance(sv, list) else sv
    contrib = pd.Series(sv_pos[0], index=FEATURES).abs().sort_values(ascending=False).head(top_k)
    return {"shap_top_features": contrib.to_dict()}

print("Artifacts saved to", ARTIFACT_DIR)
