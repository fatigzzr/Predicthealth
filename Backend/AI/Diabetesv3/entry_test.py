import os
import joblib
import pandas as pd

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetesv3/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]

def preprocess_patient(df_in):
    df = df_in.copy()
    used_feats = [
        "Sex", "Smoker", "Fruits", "Veggies", "HvyAlcoholConsump",
        "DiffWalk", "PhysActivity", "MentHlth", "PhysHlth"
    ]
    df = df[[c for c in used_feats if c in df.columns]].copy()

    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

    cont_feats = ["PhysHlth", "MentHlth"]
    for c in cont_feats:
        if c not in df.columns:
            df[c] = 0
    df[cont_feats] = scaler.transform(df[cont_feats].values)

    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    df = df[FEATURES].copy()
    return df

# --- Single patient data ---
patient_data = pd.DataFrame([{
    "Sex": 0,
    "Smoker": 1,
    "Fruits": 0,
    "Veggies": 0,
    "HvyAlcoholConsump": 1,
    "DiffWalk": 1,
    "PhysActivity": 0,
    "MentHlth": 28,
    "PhysHlth": 29
}])

X_patient = preprocess_patient(patient_data)
y_prob = calibrated.predict_proba(X_patient)[:, 1]

# --- Scale threshold-relative risk to 0-100% ---
threshold = 0.2
raw_risk = y_prob[0] / threshold
risk_percentage = min(raw_risk / 1.75 * 100, 100)  # scale so 175% → 100%

# --- Risk level ranges (0-100%) ---
if risk_percentage <= 30:
    risk_level = 1
    risk_label = "Muy Bajo"
elif risk_percentage <= 60:
    risk_level = 2
    risk_label = "Bajo"
elif risk_percentage <= 80:
    risk_level = 3
    risk_label = "Medio"
elif risk_percentage <= 90:
    risk_level = 4
    risk_label = "Alto"
else:
    risk_level = 5
    risk_label = "Muy Alto"

print(f"Model probability: {y_prob[0]:.4f}")
print(f"Riesgo escalado: {risk_percentage:.1f}%")
print(f"Nivel de riesgo ({risk_level}/5): {risk_label}")
