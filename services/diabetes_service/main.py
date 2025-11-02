import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from shared.db import get_conn
from datetime import date
from scipy import stats

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetesv2/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]
train_probs = joblib.load(os.path.join(ARTIFACT_DIR, "train_probs.joblib"))["train_probs"]

# --- Helper functions ---
def get_patient_data(user_id: int) -> pd.DataFrame:
    """Gather all needed patient features from database"""
    try:
        with get_conn() as conn:
            # Paciente info
            paciente = pd.read_sql("""
                SELECT fecha_nacimiento, sexo
                FROM Paciente WHERE id_usuario = %s
            """, conn, params=(user_id,))
            if paciente.empty:
                raise HTTPException(status_code=404, detail="Patient not found")

            # Age
            fecha_nac = paciente.loc[0, "fecha_nacimiento"]
            age_years = (date.today() - fecha_nac).days // 365

            # Sex
            sex = 1 if paciente.loc[0, "sexo"] == 'M' else 0

            # Lifestyle responses
            lifestyle = pd.read_sql("""
                SELECT p.pregunta, r.valor
                FROM Respuesta_Estilo_Vida r
                JOIN Pregunta p ON r.id_pregunta = p.id_pregunta
                WHERE r.id_usuario = %s
                ORDER BY r.fecha DESC
            """, conn, params=(user_id,))

            # Map lifestyle to features (adjust the names if your Pregunta table differs)
            lifestyle_map = {row["pregunta"]: row["valor"] for _, row in lifestyle.iterrows()}

            def map_binary(val):
                if str(val).lower() in ["yes", "sí", "si", "1", "true"]:
                    return 1
                return 0

            phys_activity = map_binary(lifestyle_map.get("PhysActivity", 0))
            fruits = map_binary(lifestyle_map.get("Fruits", 0))
            veggies = map_binary(lifestyle_map.get("Veggies", 0))
            smoker = map_binary(lifestyle_map.get("Smoker", 0))
            heavy_alcohol = map_binary(lifestyle_map.get("HvyAlcoholConsump", 0))
            diff_walk = map_binary(lifestyle_map.get("DiffWalk", 0))
            gen_health = lifestyle_map.get("GenHlth", "Good")  # Default Good

            gen_map = {"Poor": 1, "Fair": 2, "Good": 3, "Very good": 4, "Excellent": 5}
            gen_health_ord = gen_map.get(gen_health, 3)

            # Historial de enfermedades
            enfermedades = pd.read_sql("""
                SELECT e.nombre
                FROM Historial_Enfermedad he
                JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
                JOIN Historial_Medico hm ON he.id_historial = hm.id_historial
                WHERE hm.id_usuario = %s
            """, conn, params=(user_id,))
            disease_list = enfermedades["nombre"].tolist()
            stroke = 1 if any("stroke" in d.lower() for d in disease_list) else 0
            heart_attack = 1 if any("heart" in d.lower() or "attack" in d.lower() for d in disease_list) else 0

            # BMI from Historial_Medico
            bmi_res = pd.read_sql("""
                SELECT valor::float AS BMI
                FROM Historial_Medico hm
                JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion
                WHERE hm.id_usuario = %s AND tm.nombre = 'BMI'
                ORDER BY fecha DESC LIMIT 1
            """, conn, params=(user_id,))
            bmi = bmi_res["BMI"].iloc[0] if not bmi_res.empty else 25.0  # default BMI

            # PhysHlth / MentHlth - placeholder defaults if not in db
            phys_hlth = float(lifestyle_map.get("PhysHlth", 0))
            ment_hlth = float(lifestyle_map.get("MentHlth", 0))

            # Derived
            age_ord = age_years // 5  # simple ordinal
            bmi_x_age = bmi * age_ord

            # Build DataFrame
            df = pd.DataFrame([{
                "BMI": bmi,
                "PhysHlth": phys_hlth,
                "MentHlth": ment_hlth,
                "Age_ord": age_ord,
                "GenHlth_ord": gen_health_ord,
                "HighBP": 0,  # Placeholder, need lab mapping if available
                "HighChol": 0,  # Placeholder
                "Smoker": smoker,
                "Stroke": stroke,
                "HeartDiseaseorAttack": heart_attack,
                "PhysActivity": phys_activity,
                "Fruits": fruits,
                "Veggies": veggies,
                "HvyAlcoholConsump": heavy_alcohol,
                "DiffWalk": diff_walk,
                "Sex": sex,
                "BMI_x_Age": bmi_x_age
            }])
            return df

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def preprocess_patient(df_in):
    df = df_in.copy()
    num_for_scaler = ["BMI", "PhysHlth", "MentHlth", "Age_ord", "GenHlth_ord", "BMI_x_Age"]
    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    df = df[FEATURES].copy()
    df[num_for_scaler] = scaler.transform(df[num_for_scaler])
    return df

def predict_risk(user_id: int):
    df = get_patient_data(user_id)
    p = preprocess_patient(df)
    prob = calibrated.predict_proba(p)[:, 1][0]
    percentile = float(stats.percentileofscore(train_probs, prob, kind="weak"))
    threshold = 0.2
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

@app.get("/predict/{user_id}")
def predict(user_id: int):
    return {"user_id": user_id, "prediction": predict_risk(user_id)}
