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
DATA_PATH = "Backend/AI/diabetesv2/diabetes_train.csv"
ARTIFACT_DIR = "Backend/AI/diabetesv2/artifacts"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

# Load data
df = pd.read_csv(DATA_PATH)

# Target encoding
df["Diabetes_binary"] = df["Diabetes_binary"].map({"Diabetic": 1, "Non-Diabetic": 0})

# Age ordinal mapping
age_order = [
    "18 to 24", "25 to 29", "30 to 34", "35 to 39", "40 to 44",
    "45 to 49", "50 to 54", "55 to 59", "60 to 64", "65 to 69",
    "70 to 74", "75 to 79", "80 or older"
]
age_map = {v: i for i, v in enumerate(age_order)}
df["Age_ord"] = df["Age"].map(age_map).fillna(pd.Series(df["Age"].factorize()[0], index=df.index))

# GenHlth ordinal mapping
gen_map = {"Poor": 1, "Fair": 2, "Good": 3, "Very good": 4, "Excellent": 5}
df["GenHlth_ord"] = df["GenHlth"].map(gen_map).fillna(pd.to_numeric(df["GenHlth"], errors="coerce")).fillna(3)

# Ensure Sex numeric
if df["Sex"].dtype == object:
    df["Sex"] = df["Sex"].map({"Male": 1, "Female": 0}).fillna(pd.to_numeric(df["Sex"], errors="coerce")).fillna(0).astype(int)

# Feature sets (removed Education, Income, CholCheck, AnyHealthcare, NoDocbcCost)
cont_feats = ["BMI", "PhysHlth", "MentHlth"]
ord_feats = ["Age_ord", "GenHlth_ord"]
bin_feats = [
    "HighBP", "HighChol", "Smoker", "Stroke", "HeartDiseaseorAttack",
    "PhysActivity", "Fruits", "Veggies", "HvyAlcoholConsump", "DiffWalk", "Sex"
]
FEATURES = cont_feats + ord_feats + bin_feats

# Ensure all features exist
FEATURES = [c for c in FEATURES if c in df.columns]

X = df[FEATURES].copy()
y = df["Diabetes_binary"].astype(int).values

# Impute continuous features
X[cont_feats] = X[cont_feats].fillna(X[cont_feats].median())

# Derived features
X["BMI_x_Age"] = X["BMI"] * X["Age_ord"]
FEATURES += ["BMI_x_Age"]

# Standard scaling
num_for_scaler = cont_feats + ["Age_ord", "GenHlth_ord", "BMI_x_Age"]
scaler = StandardScaler()
X[num_for_scaler] = scaler.fit_transform(X[num_for_scaler])

# Cross-validation
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)

# Optuna objective
def objective(trial):
    params = {
        "n_estimators": trial.suggest_int("n_estimators", 300, 800),
        "learning_rate": trial.suggest_float("learning_rate", 0.01, 0.15, log=True),
        "num_leaves": trial.suggest_int("num_leaves", 16, 256),
        "max_depth": trial.suggest_int("max_depth", 4, 12),
        "min_child_samples": trial.suggest_int("min_child_samples", 10, 100),
        "subsample": trial.suggest_float("subsample", 0.6, 1.0),
        "colsample_bytree": trial.suggest_float("colsample_bytree", 0.6, 1.0),
        "reg_alpha": trial.suggest_float("reg_alpha", 0.0, 2.0),
        "reg_lambda": trial.suggest_float("reg_lambda", 0.0, 2.0),
        "min_gain_to_split": 0.0,
        "random_state": RANDOM_STATE,
        "n_jobs": -1,
    }
    model = LGBMClassifier(**params)
    scores = cross_val_score(model, X, y, scoring="roc_auc", cv=cv, n_jobs=-1)
    return float(np.mean(scores))

study = optuna.create_study(direction="maximize", study_name="lgbm_diabetes_auc")
study.optimize(objective, n_trials=50, show_progress_bar=True)

best_params = study.best_params
best_params.update({"random_state": RANDOM_STATE, "n_jobs": -1})

# Train final model
final_model = LGBMClassifier(**best_params)
final_model.fit(X, y)

# Calibrate classifier
calibrated = CalibratedClassifierCV(final_model, cv=cv, method="sigmoid")
calibrated.fit(X, y)

# Save model artifacts
joblib.dump({
    "scaler": scaler,
    "model": final_model,
    "calibrated": calibrated,
    "features": FEATURES,
    "best_params": best_params,
    "optuna_study": study
}, os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))

# SHAP explainer
explainer = shap.TreeExplainer(final_model)
shap_values = explainer.shap_values(X, check_additivity=False)
joblib.dump({"explainer": explainer, "shap_values": shap_values}, os.path.join(ARTIFACT_DIR, "shap.joblib"))

# Train probabilities for percentile computation
train_probs = calibrated.predict_proba(X)[:, 1]

# Unified preprocessing function
def preprocess_patient(patient_df):
    if isinstance(patient_df, dict):
        patient_df = pd.DataFrame([patient_df])
    p = patient_df.copy()
    # Age ordinal
    if "Age" in p.columns:
        p["Age_ord"] = p["Age"].map(age_map).fillna(pd.Series(p["Age"].factorize()[0], index=p.index))
    # GenHlth ordinal
    if "GenHlth" in p.columns:
        p["GenHlth_ord"] = p["GenHlth"].map(gen_map).fillna(pd.to_numeric(p["GenHlth"], errors="coerce")).fillna(3)
    # Derived features
    if "BMI" in p.columns and "Age_ord" in p.columns:
        p["BMI_x_Age"] = p["BMI"] * p["Age_ord"]
    # Ensure all features exist
    for c in FEATURES:
        if c not in p.columns:
            p[c] = 0
    # Reorder to match training
    p = p[FEATURES].copy()
    # Scale numeric
    p[num_for_scaler] = scaler.transform(p[num_for_scaler])
    return p

# Risk prediction
def predict_risk(patient_df):
    p = preprocess_patient(patient_df)
    prob = calibrated.predict_proba(p)[:, 1][0]
    percentile = float(stats.percentileofscore(train_probs, prob, kind="weak"))
    threshold = 0.5
    distance_to_threshold = prob - threshold
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
        "distance_to_threshold": float(distance_to_threshold),
        "risk_category": cat
    }

# SHAP explanation
def explain_patient(patient_df, top_k=8):
    p = preprocess_patient(patient_df)
    sv = explainer.shap_values(p, check_additivity=False)
    sv_pos = sv[1] if isinstance(sv, list) else sv
    contrib = pd.Series(sv_pos[0], index=FEATURES).abs().sort_values(ascending=False).head(top_k)
    return {
        "shap_top_features": contrib.to_dict(),
        "shap_values_full": dict(zip(FEATURES, sv_pos[0]))
    }

# Example usage
sample = df.iloc[0:1].copy()
res = predict_risk(sample)
print("Example risk for first row:", res)

# Save train_probs
joblib.dump({"train_probs": train_probs}, os.path.join(ARTIFACT_DIR, "train_probs.joblib"))
print("Artifacts saved to", ARTIFACT_DIR)
