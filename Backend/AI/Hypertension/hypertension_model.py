import os
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.calibration import CalibratedClassifierCV
from lightgbm import LGBMClassifier
from scipy import stats
import shap

RANDOM_STATE = 0
DATA_PATH = "Backend/AI/Hypertension/split/hypertension_train.csv"
ARTIFACT_DIR = "Backend/AI/Hypertension/artifacts"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

# Load
df = pd.read_csv(DATA_PATH)

# Target
df["Has_Hypertension"] = df["Has_Hypertension"].map({"Yes": 1, "No": 0}).astype(int)

# Remove Family_History completely
df = df.drop(columns=["Family_History"])

# Basic preprocessing and feature selection
NUMERIC = ["Age", "Salt_Intake", "Stress_Score", "Sleep_Duration", "BMI"]
CATEGORICAL = ["BP_History", "Medication", "Exercise_Level", "Smoking_Status"]

# Clean/normalize text columns
df[CATEGORICAL] = df[CATEGORICAL].fillna("Unknown").astype(str)

# One-hot encode categories
X_cat = pd.get_dummies(df[CATEGORICAL], drop_first=True)
X_num = df[NUMERIC].apply(pd.to_numeric, errors="coerce").fillna(df[NUMERIC].median())
X = pd.concat([X_num, X_cat], axis=1)
y = df["Has_Hypertension"].values

# Scale numeric features
scaler = StandardScaler()
X_num_scaled = pd.DataFrame(scaler.fit_transform(X_num), columns=NUMERIC, index=X.index)
X.loc[:, NUMERIC] = X_num_scaled

# CV
cv = StratifiedKFold(n_splits=4, shuffle=True, random_state=RANDOM_STATE)

# LightGBM
model = LGBMClassifier(
    n_estimators=200,
    learning_rate=0.07,
    num_leaves=31,
    max_depth=5,
    random_state=RANDOM_STATE,
    n_jobs=-1
)

# CV AUC
scores = cross_val_score(model, X, y, scoring="roc_auc", cv=cv, n_jobs=1)
print("CV AUC mean:", float(np.mean(scores)))

# Fit model + calibrate
model.fit(X, y)
calibrated = CalibratedClassifierCV(model, cv=cv, method="sigmoid")
calibrated.fit(X, y)

# Save artifacts
joblib.dump({
    "scaler": scaler,
    "model": model,
    "calibrated": calibrated,
    "feature_columns": X.columns.tolist(),
}, os.path.join(ARTIFACT_DIR, "hypertension_pipeline.joblib"))

# SHAP
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X, check_additivity=False)
joblib.dump({"explainer": explainer, "shap_values": shap_values},
            os.path.join(ARTIFACT_DIR, "shap.joblib"))

# Train probabilities
train_probs = calibrated.predict_proba(X)[:, 1]
joblib.dump({"train_probs": train_probs},
            os.path.join(ARTIFACT_DIR, "train_probs.joblib"))

# Utilities
def preprocess_patient(p):
    if isinstance(p, dict):
        p = pd.DataFrame([p])
    p = p.copy()

    for c in NUMERIC:
        if c not in p:
            p[c] = X_num[c].median()

    for c in CATEGORICAL:
        if c not in p:
            p[c] = "Unknown"

    p_num = pd.DataFrame(scaler.transform(p[NUMERIC]), columns=NUMERIC, index=p.index)
    p_cat = pd.get_dummies(p[CATEGORICAL].astype(str), drop_first=True)

    p_full = pd.concat([p_num, p_cat], axis=1)
    p_full = p_full.reindex(columns=X.columns, fill_value=0)
    return p_full

def predict_risk(patient):
    p = preprocess_patient(patient)
    prob = float(calibrated.predict_proba(p)[:, 1][0])
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
        "probability": prob,
        "percentage": prob * 100.0,
        "percentile": percentile,
        "risk_category": cat
    }

def explain_patient(patient, top_k=6):
    p = preprocess_patient(patient)
    sv = explainer.shap_values(p, check_additivity=False)
    sv_pos = sv[1] if isinstance(sv, list) else sv
    contrib = pd.Series(sv_pos[0], index=X.columns).abs().sort_values(ascending=False).head(top_k)
    return {"shap_top_features": contrib.to_dict()}

print("Training complete. Artifacts saved to", ARTIFACT_DIR)
