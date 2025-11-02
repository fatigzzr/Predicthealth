import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from services.shared.db import get_conn
from datetime import date
from scipy import stats

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetesv2/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]
train_probs = joblib.load(os.path.join(ARTIFACT_DIR, "train_probs.joblib"))["train_probs"]
APP_PORT = 8008

# --- Helper functions ---
def get_patient_data(user_id: int) -> pd.DataFrame:
    """Gather all needed patient features from database safely."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # --- Paciente info ---
                cur.execute("""
                    SELECT fecha_nacimiento, sexo
                    FROM Paciente
                    WHERE id_usuario = %s
                """, (user_id,))
                rows = cur.fetchall()
                if not rows:
                    raise HTTPException(status_code=404, detail="Patient not found")
                columns = [desc[0] for desc in cur.description]
                paciente = pd.DataFrame(rows, columns=columns)

                # Age
                fecha_nac = paciente.loc[0, "fecha_nacimiento"]
                age_years = (date.today() - fecha_nac).days // 365

                # Sex
                sex = 1 if paciente.loc[0, "sexo"] == 'M' else 0

                # --- Lifestyle responses ---
                cur.execute("""
                    SELECT p.pregunta, r.valor
                    FROM Respuesta_Estilo_Vida r
                    JOIN Pregunta p ON r.id_pregunta = p.id_pregunta
                    WHERE r.id_usuario = %s
                    ORDER BY r.fecha DESC
                """, (user_id,))
                rows = cur.fetchall()
                columns = [desc[0] for desc in cur.description]
                lifestyle = pd.DataFrame(rows, columns=columns)

                lifestyle_map = {row["pregunta"]: row["valor"] for _, row in lifestyle.iterrows()}

                def map_binary(val):
                    return 1 if str(val).lower() in ["yes", "sí", "si", "1", "true"] else 0

                phys_activity = map_binary(lifestyle_map.get("PhysActivity", 0))
                fruits = map_binary(lifestyle_map.get("Fruits", 0))
                veggies = map_binary(lifestyle_map.get("Veggies", 0))
                smoker = map_binary(lifestyle_map.get("Smoker", 0))
                heavy_alcohol = map_binary(lifestyle_map.get("HvyAlcoholConsump", 0))
                diff_walk = map_binary(lifestyle_map.get("DiffWalk", 0))
                gen_health = lifestyle_map.get("GenHlth", "Good")
                gen_map = {"Poor": 1, "Fair": 2, "Good": 3, "Very good": 4, "Excellent": 5}
                gen_health_ord = gen_map.get(gen_health, 3)

                # --- Diseases ---
                cur.execute("""
                    SELECT e.nombre
                    FROM Historial_Enfermedad he
                    JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
                    JOIN Historial_Medico hm ON he.id_historial = hm.id_historial
                    WHERE hm.id_usuario = %s
                """, (user_id,))
                rows = cur.fetchall()
                disease_list = [r[0] for r in rows]
                stroke = 1 if any("stroke" in d.lower() for d in disease_list) else 0
                heart_attack = 1 if any("heart" in d.lower() or "attack" in d.lower() for d in disease_list) else 0

                # --- BMI ---
                cur.execute("""
                    SELECT valor::float AS BMI
                    FROM Historial_Medico hm
                    JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion
                    WHERE hm.id_usuario = %s AND tm.nombre = 'BMI'
                    ORDER BY fecha DESC
                    LIMIT 1
                """, (user_id,))
                rows = cur.fetchall()
                bmi = rows[0][0] if rows else 25.0

                # PhysHlth / MentHlth placeholders
                phys_hlth = float(lifestyle_map.get("PhysHlth", 0))
                ment_hlth = float(lifestyle_map.get("MentHlth", 0))

                # Derived
                age_ord = age_years // 5
                bmi_x_age = bmi * age_ord

                # Build DataFrame
                df = pd.DataFrame([{
                    "BMI": bmi,
                    "PhysHlth": phys_hlth,
                    "MentHlth": ment_hlth,
                    "Age_ord": age_ord,
                    "GenHlth_ord": gen_health_ord,
                    "HighBP": 0,
                    "HighChol": 0,
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
        raise HTTPException(status_code=500, detail=f"DB error: {e}")


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


# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
