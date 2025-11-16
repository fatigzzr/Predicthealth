import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from services.shared.db import get_conn
from datetime import date
import json
from psycopg2.extras import Json

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/Hypertension/artifacts"
try:
    pipeline_path = os.path.join(ARTIFACT_DIR, "hypertension_pipeline.joblib")
    if not os.path.exists(pipeline_path):
        raise FileNotFoundError(f"Model file not found: {pipeline_path}")
    pipeline = joblib.load(pipeline_path)
    scaler = pipeline["scaler"]
    calibrated = pipeline["calibrated"]
    FEATURES = pipeline["features"]
    print(f"Successfully loaded hypertension model with {len(FEATURES)} features")
except Exception as e:
    import traceback
    print(f"ERROR loading model: {traceback.format_exc()}")
    raise

APP_PORT = 8009

# --- Mapping id_pregunta to model features (hypertension model) ---
# Hypertension model features: Age, Salt_Intake, Stress_Score, BP_History, Sleep_Duration, BMI, Medication, Family_History, Exercise_Level, Smoking_Status
PREGUNTA_TO_FEATURE = {
    4: "Smoking_Status",  # ¿Fuma?
    # 5: "Medication",     #missing - no pregunta maps to current medications in estilo_vida
    # 7: "Family_History", #missing - family history not captured
    # 8: "BP_History",     #missing - blood pressure history not in estilo_vida
    # 10: "Sleep_Duration",#missing - sleep hours tracked in step 8 but not persisted to estilo_vida
    # 13: "Exercise_Level",#missing - exercise level not captured as structured data
    14: "Stress_Score",   # stress level (1-10) from step 8
    # 15: "Salt_Intake",   #missing - salt intake from step 7 but units may not match model
}

# --- Helper functions ---
def get_patient_data(user_id: int) -> pd.DataFrame:
    """Gather all needed patient features from database for hypertension prediction."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # --- Get Age, BMI from Paciente (newest fecha) ---
                cur.execute("""
                    SELECT sexo, fecha_nacimiento
                    FROM Paciente
                    WHERE id_usuario = %s
                    ORDER BY fecha DESC
                    LIMIT 1
                """, (user_id,))
                row = cur.fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Patient not found")
                
                # Calculate Age from fecha_nacimiento
                from datetime import datetime
                birth_date = row["fecha_nacimiento"]
                today = datetime.now().date()
                age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
                
                # --- Get lifestyle/salud responses (newest fecha per id_pregunta) ---
                cur.execute("""
                    SELECT id_pregunta, valor
                    FROM (
                        SELECT 
                            id_pregunta, 
                            valor,
                            fecha,
                            ROW_NUMBER() OVER (PARTITION BY id_pregunta ORDER BY fecha DESC NULLS LAST, id_respuesta DESC) as rn
                        FROM Respuesta_Estilo_Vida
                        WHERE id_usuario = %s
                    ) ranked
                    WHERE rn = 1
                    ORDER BY id_pregunta
                """, (user_id,))
                estilo_rows = cur.fetchall()
                estilo_map = {row["id_pregunta"]: row["valor"] for row in estilo_rows}
                
                # --- Get Salud responses (for BMI, pressure, etc.) ---
                cur.execute("""
                    SELECT id_pregunta, valor
                    FROM (
                        SELECT 
                            id_pregunta, 
                            valor,
                            fecha,
                            ROW_NUMBER() OVER (PARTITION BY id_pregunta ORDER BY fecha DESC NULLS LAST, id_respuesta DESC) as rn
                        FROM Respuesta_Salud
                        WHERE id_usuario = %s
                    ) ranked
                    WHERE rn = 1
                    ORDER BY id_pregunta
                """, (user_id,))
                salud_rows = cur.fetchall()
                salud_map = {row["id_pregunta"]: row["valor"] for row in salud_rows}
                
                print(f"DEBUG: estilo_map for user {user_id}: {estilo_map}")
                print(f"DEBUG: salud_map for user {user_id}: {salud_map}")

                # Map binary values (si/no questions)
                def map_binary(val):
                    if val is None:
                        return 0
                    val_str = str(val).strip()
                    if val_str.upper() in ["TRUE", "YES", "SÍ", "SI", "1", "S", "Y"]:
                        return 1
                    return 0

                def map_numeric(val, default=0):
                    if val is None:
                        return default
                    try:
                        return float(val)
                    except (ValueError, TypeError):
                        return default

                # Extract hypertension model features
                # Age: calculated from fecha_nacimiento
                age_val = age
                
                # Salt_Intake: from estilo_vida pregunta 15 (if available) #missing - may need validation
                salt_intake = map_numeric(estilo_map.get(15, 0), 0)  # #missing
                
                # Stress_Score: from estilo_vida pregunta 14 (stress level 1-10)
                stress_score = map_numeric(estilo_map.get(14, 0), 5)  # #missing - assuming default 5 if not found
                
                # BP_History: from salud pregunta (presion arterial) #missing - may not be boolean
                bp_history = 0  # #missing - need to map from presion responses
                
                # Sleep_Duration: from estilo_vida pregunta 13 #missing - not yet in responses
                sleep_duration = map_numeric(estilo_map.get(13, 0), 7)  # #missing - assuming default 7 hours
                
                # BMI: from salud pregunta (BMI field) #missing - need to extract from salud responses
                bmi = map_numeric(salud_map.get(5, 0), 25)  # #missing - assuming default 25 if not found
                
                # Medication: from salud responses #missing - no direct pregunta for current medications
                medication = 0  # #missing
                
                # Family_History: from salud responses #missing - family history not captured
                family_history = 0  # #missing
                
                # Exercise_Level: from estilo_vida #missing - need structured exercise level
                exercise_level = map_numeric(estilo_map.get(11, 0), 0)  # #missing - using phys_activity proxy
                
                # Smoking_Status: from estilo_vida pregunta 4 (¿Fuma?)
                smoking_status = map_binary(estilo_map.get(4, 0))
                
                # Build DataFrame matching the model's expected format
                df = pd.DataFrame([{
                    "Age": age_val,
                    "Salt_Intake": salt_intake,
                    "Stress_Score": stress_score,
                    "BP_History": bp_history,
                    "Sleep_Duration": sleep_duration,
                    "BMI": bmi,
                    "Medication": medication,
                    "Family_History": family_history,
                    "Exercise_Level": exercise_level,
                    "Smoking_Status": smoking_status
                }])
                
                # Debug: Print processed values
                print(f"DEBUG: Processed hypertension features for user {user_id}:")
                print(f"  Age={age_val}, Salt_Intake={salt_intake}, Stress_Score={stress_score}")
                print(f"  BP_History={bp_history}, Sleep_Duration={sleep_duration}, BMI={bmi}")
                print(f"  Medication={medication}, Family_History={family_history}")
                print(f"  Exercise_Level={exercise_level}, Smoking_Status={smoking_status}")
                
                return df

    except HTTPException:
        raise
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Error in get_patient_data: {error_trace}")
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")


def preprocess_patient(df_in):
    """Preprocess patient data to match hypertension model requirements."""
    df = df_in.copy()
    used_feats = [
        "Age", "Salt_Intake", "Stress_Score", "BP_History", "Sleep_Duration",
        "BMI", "Medication", "Family_History", "Exercise_Level", "Smoking_Status"
    ]
    df = df[[c for c in used_feats if c in df.columns]].copy()

    # Ensure numeric
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

    # Scale continuous features if scaler expects them
    cont_feats = ["Age", "Salt_Intake", "Stress_Score", "Sleep_Duration", "BMI"]
    for c in cont_feats:
        if c not in df.columns:
            df[c] = 0
    
    # Transform continuous features with scaler (if applicable)
    if hasattr(scaler, 'transform'):
        try:
            df[cont_feats] = scaler.transform(df[cont_feats].values)
        except Exception as e:
            print(f"Warning: scaler transform failed: {e}")

    # Ensure all FEATURES are present
    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    df = df[FEATURES].copy()
    return df


def predict_risk(user_id: int):
    """Predict hypertension risk for a user."""
    df = get_patient_data(user_id)
    X_patient = preprocess_patient(df)
    
    # Debug: Print preprocessed features
    print(f"DEBUG: Preprocessed features (first row):")
    for col in X_patient.columns:
        print(f"  {col}={X_patient[col].iloc[0]}")
    
    y_prob = calibrated.predict_proba(X_patient)[:, 1][0]
    
    # Debug: Print raw probability
    print(f"DEBUG: Raw model probability: {y_prob:.6f}")

    # --- Scale threshold-relative risk to 0-100% ---
    # Threshold is 0.2 - anything above this is concerning
    # Scale so that 0.36 (1.8x threshold) maps to 100%
    # Formula: risk_percentage = min((y_prob / threshold) / 1.75 * 100, 100)
    threshold = 0.2
    raw_risk = y_prob / threshold
    risk_percentage = float(min(raw_risk / 1.75 * 100, 100))

    # --- Risk level ranges based on percentage (0-100%) ---
    if risk_percentage <= 20:
        risk_level = 1
        risk_label = "Muy Bajo"
    elif risk_percentage <= 40:
        risk_level = 2
        risk_label = "Bajo"
    elif risk_percentage <= 60:
        risk_level = 3
        risk_label = "Medio"
    elif risk_percentage <= 80:
        risk_level = 4
        risk_label = "Alto"
    else:  # 81-100
        risk_level = 5
        risk_label = "Muy Alto"
    
    print(f"DEBUG: Scaled risk percentage: {risk_percentage:.2f}%")

    return {
        "probability": float(y_prob),
        "percentage": risk_percentage,
        "risk_level": risk_level,
        "risk_label": risk_label
    }


# --- FastAPI setup ---
app = FastAPI(title="Hypertension Risk Service", version="2.0")


@app.get("/predict_hypertension/{user_id}")
def predict(user_id: int):
    """Predict hypertension risk for a user by ID."""
    try:
        result = predict_risk(user_id)
        # After computing the prediction, persist a row to Prediccion table (best-effort)
        try:
            probability = float(result.get("probability", 0.0))
            pred_bool = True if probability > 0.2 else False
            with get_conn() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, probabilidad, fecha, explicabilidad)
                        VALUES (%s, %s, %s, %s, %s, NOW(), %s)
                        RETURNING id_prediccion
                        """,
                        (2, user_id, 2, pred_bool, probability, Json({}))
                    )
                    inserted = cur.fetchone()
                    if inserted and 'id_prediccion' in inserted:
                        pred_id = inserted['id_prediccion']
                        print(f"Inserted Prediccion id={pred_id} for user={user_id} prob={probability}")
                    else:
                        print(f"Inserted Prediccion (no id returned) for user={user_id} prob={probability}")
        except Exception as db_ex:
            import traceback
            print(f"Warning: could not insert Prediccion row: {traceback.format_exc()}")
        return {"user_id": user_id, "prediction": result}
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Error in predict endpoint: {error_trace}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.get("/prediccion/latest/{user_id}")
def latest_predicciones(user_id: int):
    """Return the latest Prediccion rows for diabetes (1) and hypertension (2) for a user."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT DISTINCT ON (id_enfermedad)
                        id_enfermedad, probabilidad, prediccion, fecha
                    FROM Prediccion
                    WHERE id_usuario = %s AND id_enfermedad IN (1,2)
                    ORDER BY id_enfermedad, fecha DESC
                    """,
                    (user_id,)
                )
                rows = cur.fetchall()
                result = {"user_id": user_id, "predictions": []}
                for r in rows:
                    id_enf = r.get('id_enfermedad')
                    prob = r.get('probabilidad')
                    pred_bool = r.get('prediccion')
                    fecha = r.get('fecha')
                    # compute a display percentage for diabetes using same scaling as predict_risk
                    pct = None
                    if prob is not None:
                        try:
                            prob_f = float(prob)
                            if id_enf == 1:
                                threshold = 0.2
                                raw_risk = prob_f / threshold
                                pct = float(min(raw_risk / 1.75 * 100, 100))
                            else:
                                pct = float(min(prob_f * 100, 100))
                        except Exception:
                            pct = None

                    result['predictions'].append({
                        'id_enfermedad': id_enf,
                        'probabilidad': prob,
                        'percentage': pct,
                        'prediccion': pred_bool,
                        'fecha': str(fecha) if fecha is not None else None
                    })
                return result
    except Exception as e:
        import traceback
        print(f"Error fetching latest prediccion: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/prediccion/latest/hypertension/{user_id}")
def latest_prediccion_hypertension(user_id: int):
    """Return the newest Prediccion row for hypertension (id_enfermedad=2) for a user."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT id_enfermedad, probabilidad, prediccion, fecha
                    FROM Prediccion
                    WHERE id_usuario = %s AND id_enfermedad = 2
                    ORDER BY fecha DESC
                    LIMIT 1
                    """,
                    (user_id,)
                )
                row = cur.fetchone()
                if not row:
                    # return empty result indicating no prediction
                    return {"user_id": user_id, "prediction": None}

                prob = row.get('probabilidad')
                pred_bool = row.get('prediccion')
                fecha = row.get('fecha')

                pct = None
                if prob is not None:
                    try:
                        prob_f = float(prob)
                        # For hypertension, scale probability directly (threshold may differ)
                        pct = float(min(prob_f * 100, 100))
                    except Exception:
                        pct = None

                return {
                    'user_id': user_id,
                    'prediction': {
                        'id_enfermedad': 2,
                        'probabilidad': prob,
                        'percentage': pct,
                        'prediccion': pred_bool,
                        'fecha': str(fecha) if fecha is not None else None
                    }
                }
    except Exception as e:
        import traceback
        print(f"Error fetching latest hypertension prediccion: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))


# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
