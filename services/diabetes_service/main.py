import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from services.shared.db import get_conn
from datetime import date
import json
from psycopg2.extras import Json

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetesv3/artifacts"
try:
    pipeline_path = os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib")
    if not os.path.exists(pipeline_path):
        raise FileNotFoundError(f"Model file not found: {pipeline_path}")
    pipeline = joblib.load(pipeline_path)
    scaler = pipeline["scaler"]
    calibrated = pipeline["calibrated"]
    FEATURES = pipeline["features"]
    print(f"Successfully loaded diabetes v3 model with {len(FEATURES)} features")
except Exception as e:
    import traceback
    print(f"ERROR loading model: {traceback.format_exc()}")
    raise

APP_PORT = 8008

# --- Mapping id_pregunta to model features ---
PREGUNTA_TO_FEATURE = {
    1: "Fruits",
    2: "Veggies",
    4: "Smoker",
    5: "HvyAlcoholConsump",
    6: "DiffWalk",
    9: "MentHlth",
    11: "PhysActivity",
    12: "PhysHlth"
}

# --- Helper functions ---
def get_patient_data(user_id: int) -> pd.DataFrame:
    """Gather all needed patient features from database."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # --- Get Sex from Paciente (newest fecha) ---
                cur.execute("""
                    SELECT sexo
                    FROM Paciente
                    WHERE id_usuario = %s
                    ORDER BY fecha DESC
                    LIMIT 1
                """, (user_id,))
                row = cur.fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Patient not found")
                sexo_value = row["sexo"]
                sex = 1 if sexo_value == 'M' else 0

                # --- Get lifestyle responses (newest fecha per id_pregunta) ---
                # Use window function approach with explicit timestamp ordering including microseconds
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
                            AND id_pregunta IN (1, 2, 4, 5, 6, 9, 11, 12)
                    ) ranked
                    WHERE rn = 1
                    ORDER BY id_pregunta
                """, (user_id,))
                rows = cur.fetchall()
                
                # Build a map of id_pregunta -> valor
                valor_map = {row["id_pregunta"]: row["valor"] for row in rows}
                
                # Debug: Print raw values
                print(f"DEBUG: Raw valor_map for user {user_id}: {valor_map}")

                # Map binary values (si/no questions)
                def map_binary(val):
                    if val is None:
                        return 0
                    val_str = str(val).strip()
                    # Check for yes/true values (note: "Sí" becomes "SÍ" when uppercased)
                    if val_str.upper() in ["TRUE", "YES", "SÍ", "SI", "1", "S", "Y"]:
                        return 1
                    return 0

                # Extract values with proper mapping
                # Note: For worst case scenario (high risk):
                # Fruits=No (0), Veggies=No (0), Smoker=Sí (1), Alcohol=Sí (1), 
                # DiffWalk=Sí (1), PhysActivity=No (0) are all correct for high risk
                fruits = map_binary(valor_map.get(1, 0))
                veggies = map_binary(valor_map.get(2, 0))
                smoker = map_binary(valor_map.get(4, 0))
                hvy_alcohol = map_binary(valor_map.get(5, 0))
                diff_walk = map_binary(valor_map.get(6, 0))
                phys_activity = map_binary(valor_map.get(11, 0))
                
                # Extract numeric values
                def map_numeric(val, default=0):
                    if val is None:
                        return default
                    try:
                        result = float(val)
                        return max(0, min(result, 30))  # Clamp between 0-30 for health days
                    except (ValueError, TypeError):
                        return default

                ment_hlth = map_numeric(valor_map.get(9, 0))
                phys_hlth = map_numeric(valor_map.get(12, 0))

                # Build DataFrame matching the model's expected format
                df = pd.DataFrame([{
                    "Sex": sex,
                    "Smoker": smoker,
                    "Fruits": fruits,
                    "Veggies": veggies,
                    "HvyAlcoholConsump": hvy_alcohol,
                    "DiffWalk": diff_walk,
                    "PhysActivity": phys_activity,
                    "MentHlth": ment_hlth,
                    "PhysHlth": phys_hlth
                }])
                
                # Debug: Print processed values
                print(f"DEBUG: Processed features for user {user_id}:")
                print(f"  Sex={sex}, Smoker={smoker}, Fruits={fruits}, Veggies={veggies}")
                print(f"  HvyAlcoholConsump={hvy_alcohol}, DiffWalk={diff_walk}, PhysActivity={phys_activity}")
                print(f"  MentHlth={ment_hlth}, PhysHlth={phys_hlth}")
                
                return df

    except HTTPException:
        raise
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Error in get_patient_data: {error_trace}")
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")


def preprocess_patient(df_in):
    """Preprocess patient data to match model requirements."""
    df = df_in.copy()
    used_feats = [
        "Sex", "Smoker", "Fruits", "Veggies", "HvyAlcoholConsump",
        "DiffWalk", "PhysActivity", "MentHlth", "PhysHlth"
    ]
    df = df[[c for c in used_feats if c in df.columns]].copy()

    # Ensure numeric
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

    # Scale continuous features
    cont_feats = ["PhysHlth", "MentHlth"]
    for c in cont_feats:
        if c not in df.columns:
            df[c] = 0
    
    # Transform continuous features with scaler
    df[cont_feats] = scaler.transform(df[cont_feats].values)

    # Ensure all FEATURES are present
    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    df = df[FEATURES].copy()
    return df


def predict_risk(user_id: int):
    """Predict diabetes risk for a user."""
    df = get_patient_data(user_id)
    X_patient = preprocess_patient(df)
    
    # Debug: Print preprocessed features
    print(f"DEBUG: Preprocessed features (first row):")
    for col in X_patient.columns:
        print(f"  {col}={X_patient[col].iloc[0]}")
    
    y_prob = calibrated.predict_proba(X_patient)[:, 1][0]
    
    # Debug: Print raw probability
    print(f"DEBUG: Raw model probability: {y_prob:.6f}")

    # --- Scale risk using continuous exponential curve ---
    # Use a sigmoid-like transformation that continues scaling above threshold
    # This ensures cases well above threshold get appropriately higher scores
    threshold = 0.2
    
    # Apply exponential scaling: risk grows faster as probability increases
    # Formula: percentage = (prob / threshold) ^ 1.5 * 100
    # This gives continuous growth without artificial caps
    if y_prob < threshold:
        # Below threshold: gentler scaling
        risk_percentage = float((y_prob / threshold) ** 1.2 * 50.0)
    else:
        # Above threshold: accelerated scaling
        # At threshold (0.2): ~50%
        # At 2x threshold (0.4): ~100%
        # At 3x threshold (0.6): ~173%
        # At 4x threshold (0.8): ~253%
        risk_percentage = float(50.0 + ((y_prob / threshold - 1.0) ** 1.5) * 100.0)
    
    # Cap at a reasonable maximum (e.g., 300% for very high risk)
    risk_percentage = float(min(risk_percentage, 300.0))

    # --- Risk level ranges based on percentage (now 0-300% scale) ---
    if risk_percentage <= 30:
        risk_level = 1
        risk_label = "Muy Bajo"
    elif risk_percentage <= 60:
        risk_level = 2
        risk_label = "Bajo"
    elif risk_percentage <= 100:
        risk_level = 3
        risk_label = "Medio"
    elif risk_percentage <= 150:
        risk_level = 4
        risk_label = "Alto"
    else:  # 151-300
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
app = FastAPI(title="Diabetes Risk Service", version="2.0")


@app.get("/predict_diabetes/{user_id}")
def predict(user_id: int):
    """Predict diabetes risk for a user by ID."""
    print(f"=== DIABETES PREDICT CALLED FOR USER {user_id} ===")
    try:
        result = predict_risk(user_id)
        print(f"DEBUG: Prediction result: {result}")
        # After computing the prediction, persist a row to Prediccion table (best-effort)
        try:
            probability = float(result.get("probability", 0.0))
            pred_bool = True if probability > 0.2 else False
            print(f"DEBUG: About to insert Prediccion: prob={probability}, pred_bool={pred_bool}")
            conn = get_conn()
            try:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, probabilidad, fecha, explicabilidad)
                        VALUES (%s, %s, %s, %s, %s, NOW(), %s)
                        RETURNING id_prediccion
                        """,
                        (1, user_id, 1, pred_bool, probability, Json({}))
                    )
                    inserted = cur.fetchone()
                    if inserted and 'id_prediccion' in inserted:
                        pred_id = inserted['id_prediccion']
                        print(f"*** SUCCESSFULLY INSERTED Prediccion id={pred_id} for user={user_id} prob={probability} ***")
                    else:
                        print(f"*** INSERTED Prediccion (no id returned) for user={user_id} prob={probability} ***")
                # Explicitly commit before closing connection (even though autocommit=True)
                if not conn.autocommit:
                    conn.commit()
            finally:
                conn.close()
        except Exception as db_ex:
            import traceback
            print(f"!!! ERROR INSERTING PREDICCION: {traceback.format_exc()}")
        print(f"=== RETURNING PREDICTION RESPONSE ===")
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
                                if prob_f < threshold:
                                    pct = float((prob_f / threshold) ** 1.2 * 50.0)
                                else:
                                    pct = float(50.0 + ((prob_f / threshold - 1.0) ** 1.5) * 100.0)
                                pct = float(min(pct, 300.0))
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


@app.get("/prediccion/latest/diabetes/{user_id}")
def latest_prediccion_diabetes(user_id: int):
    """Return the newest Prediccion row for diabetes (id_enfermedad=1) for a user."""
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT id_enfermedad, probabilidad, prediccion, fecha
                    FROM Prediccion
                    WHERE id_usuario = %s AND id_enfermedad = 1
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
                        threshold = 0.2
                        if prob_f < threshold:
                            pct = float((prob_f / threshold) ** 1.2 * 50.0)
                        else:
                            pct = float(50.0 + ((prob_f / threshold - 1.0) ** 1.5) * 100.0)
                        pct = float(min(pct, 300.0))
                    except Exception:
                        pct = None

                return {
                    'user_id': user_id,
                    'prediction': {
                        'id_enfermedad': 1,
                        'probabilidad': prob,
                        'percentage': pct,
                        'prediccion': pred_bool,
                        'fecha': str(fecha) if fecha is not None else None
                    }
                }
    except Exception as e:
        import traceback
        print(f"Error fetching latest diabetes prediccion: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))


# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
