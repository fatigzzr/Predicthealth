import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from shared.db import get_conn

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetes/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]
train_probs = joblib.load(os.path.join(ARTIFACT_DIR, "train_probs.joblib"))["train_probs"]

# --- Helper functions ---
def preprocess_patient(patient_df):
    p = patient_df.copy()
    age_order = [
        "18 to 24", "25 to 29", "30 to 34", "35 to 39", "40 to 44",
        "45 to 49", "50 to 54", "55 to 59", "60 to 64", "65 to 69",
        "70 to 74", "75 to 79", "80 or older"
    ]
    age_map = {v: i for i, v in enumerate(age_order)}
    gen_map = {"Poor": 1, "Fair": 2, "Good": 3, "Very good": 4, "Excellent": 5}
    num_for_scaler = ["BMI", "PhysHlth", "MentHlth", "Age_ord", "GenHlth_ord", "Education", "Income", "BMI_x_Age"]

    if "Age" in p.columns:
        p["Age_ord"] = p["Age"].map(age_map).fillna(pd.Series(p["Age"].factorize()[0], index=p.index))
    if "GenHlth" in p.columns:
        p["GenHlth_ord"] = p["GenHlth"].map(gen_map).fillna(pd.to_numeric(p["GenHlth"], errors="coerce")).fillna(3)
    for col in ["Education", "Income"]:
        if col in p.columns and p[col].dtype == object:
            p[col] = pd.to_numeric(p[col], errors="coerce").fillna(0).astype(int)
    if "BMI" in p.columns and "Age_ord" in p.columns:
        p["BMI_x_Age"] = p["BMI"] * p["Age_ord"]
    for c in FEATURES:
        if c not in p.columns:
            p[c] = 0
    p = p[FEATURES].copy()
    p[num_for_scaler] = scaler.transform(p[num_for_scaler])
    return p

def predict_risk(patient_df):
    from scipy import stats
    p = preprocess_patient(patient_df)
    prob = calibrated.predict_proba(p)[:, 1][0]
    percentile = float(stats.percentileofscore(train_probs, prob, kind="weak"))
    threshold = 0.2 # 0.2 for better recall
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

# --- FastAPI setup ---
app = FastAPI(title="Diabetes Risk Service", version="1.0")

def get_patient_data(patient_id: int) -> pd.DataFrame:
    """Fetch patient features from Postgres by ID using shared/db.py"""
    try:
        with get_conn() as conn:
            query = "SELECT * FROM patients WHERE id = %s LIMIT 1;"
            df = pd.read_sql(query, conn, params=(patient_id,))
            if df.empty:
                raise HTTPException(status_code=404, detail="Patient not found")
            return df
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- API endpoint ---
@app.get("/predict/{patient_id}")
def predict(patient_id: int):
    patient_df = get_patient_data(patient_id)
    result = predict_risk(patient_df)
    return {"patient_id": patient_id, "prediction": result}
