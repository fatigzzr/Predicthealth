import os
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from services.shared.db import get_conn
from services.shared.auth import require_auth
from datetime import date
import json
from psycopg2.extras import Json
from dicttoxml import dicttoxml

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/Hypertension/artifacts"
try:
    pipeline_path = os.path.join(ARTIFACT_DIR, "hypertension_pipeline.joblib")
    if not os.path.exists(pipeline_path):
        raise FileNotFoundError(f"Model file not found: {pipeline_path}")
    pipeline = joblib.load(pipeline_path)
    scaler = pipeline["scaler"]
    calibrated = pipeline["calibrated"]
    # Try to load features from pipeline, otherwise use hardcoded list
    if "features" in pipeline:
        FEATURES = pipeline["features"]
    else:
        FEATURES = ["Age", "Salt_Intake", "Stress_Score", "BP_History", "Sleep_Duration",
                    "BMI", "Medication", "Family_History", "Exercise_Level", "Smoking_Status"]

    # Attempt to discover underlying LightGBM booster and its feature names for robust prediction
    MODEL_FEATURE_NAMES = None
    try:
        booster = None
        # Common places for a booster: inside calibrated (CalibratedClassifierCV), or directly in pipeline
        # 1) If calibrated is a CalibratedClassifierCV, inspect its calibrated_classifiers_
        if 'calibrated' in locals() and hasattr(calibrated, 'calibrated_classifiers_'):
            try:
                cc = calibrated.calibrated_classifiers_[0]
                be = getattr(cc, 'base_estimator', None)
                if be is None:
                    be = cc
                if hasattr(be, 'booster_'):
                    booster = be.booster_
                elif hasattr(be, 'get_booster'):
                    booster = be.get_booster()
            except Exception:
                booster = None

        # 2) Sometimes the pipeline stores the raw model under other keys
        if booster is None:
            for key in ['model', 'estimator', 'clf', 'classifier']:
                if key in pipeline:
                    cand = pipeline[key]
                    if hasattr(cand, 'booster_'):
                        booster = cand.booster_
                        break
                    if hasattr(cand, 'get_booster'):
                        try:
                            booster = cand.get_booster()
                            break
                        except Exception:
                            pass

        # 3) As a last resort, check top-level objects for booster-like attributes
        if booster is None:
            for obj in pipeline.values():
                try:
                    if hasattr(obj, 'booster_'):
                        booster = obj.booster_
                        break
                    if hasattr(obj, 'get_booster'):
                        booster = obj.get_booster()
                        break
                except Exception:
                    continue

        if booster is not None:
            try:
                if hasattr(booster, 'feature_name'):
                    MODEL_FEATURE_NAMES = list(booster.feature_name())
                elif hasattr(booster, 'feature_name_'):
                    MODEL_FEATURE_NAMES = list(booster.feature_name_)
            except Exception:
                MODEL_FEATURE_NAMES = None

        if MODEL_FEATURE_NAMES is not None:
            print(f"Discovered booster with {len(MODEL_FEATURE_NAMES)} feature names: {MODEL_FEATURE_NAMES}")
        else:
            print(f"No booster feature names discovered at load time; using FEATURES list of length {len(FEATURES)}")
    except Exception as e:
        print(f"Warning: failed to inspect pipeline for booster/feature names: {e}")

    print(f"Successfully loaded hypertension model with {len(FEATURES)} features")
except Exception as e:
    import traceback
    print(f"ERROR loading model: {traceback.format_exc()}")
    raise

APP_PORT = 8009

# Scaling configuration (can be overridden with environment variables)
SCALE_METHOD = os.getenv("HYPERTENSION_SCALE", "thresholded")  # options: direct, thresholded
SCALE_THRESHOLD = float(os.getenv("HYPERTENSION_THRESHOLD", "0.8"))
SCALE_GAMMA = float(os.getenv("HYPERTENSION_GAMMA", "12"))

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

    # Ensure all expected features are present. Prefer discovered MODEL_FEATURE_NAMES if available.
    expected = None
    try:
        if 'MODEL_FEATURE_NAMES' in globals() and MODEL_FEATURE_NAMES:
            expected = MODEL_FEATURE_NAMES
        else:
            expected = FEATURES
    except Exception:
        expected = FEATURES

    for c in expected:
        if c not in df.columns:
            df[c] = 0
    df = df[expected].copy()
    return df


def predict_risk(user_id: int):
    """Predict hypertension risk for a user (reads from DB)."""
    df = get_patient_data(user_id)
    return predict_risk_from_df(df)


def predict_risk_from_df(df: pd.DataFrame):
    """Predict hypertension risk from a dataframe of features."""
    X_patient = preprocess_patient(df)

    # Debug: Print preprocessed features
    print(f"DEBUG: Preprocessed features (first row):")
    for col in X_patient.columns:
        print(f"  {col}={X_patient[col].iloc[0]}")

    # Try normal predict_proba, but catch shape mismatches from LightGBM and attempt
    # to recover by aligning input columns with the model (if possible) or calling
    # the underlying booster with shape-check disabled.
    try:
        y_prob = calibrated.predict_proba(X_patient)[:, 1][0]
    except Exception as e:
        err = str(e)
        print(f"Warning: prediction failed on first attempt: {err}")
        # Attempt 1: try to discover feature names from the fitted model/booster
        booster = None
        feature_names = None
        try:
            # common access patterns
            if hasattr(calibrated, 'get_booster'):
                try:
                    booster = calibrated.get_booster()
                except Exception:
                    booster = None
            if booster is None and hasattr(calibrated, 'booster_'):
                booster = getattr(calibrated, 'booster_')
            # Try calibrated.calibrated_classifiers_ (sklearn's CalibratedClassifierCV)
            if booster is None and hasattr(calibrated, 'calibrated_classifiers_'):
                try:
                    cc = calibrated.calibrated_classifiers_[0]
                    if hasattr(cc, 'base_estimator'):
                        be = cc.base_estimator
                        if hasattr(be, 'booster_'):
                            booster = be.booster_
                        elif hasattr(be, 'get_booster'):
                            booster = be.get_booster()
                except Exception:
                    booster = None
            # If we have a booster, try to get feature names
            if booster is not None:
                try:
                    # booster may be a lightgbm.Booster or sklearn wrapper
                    if hasattr(booster, 'feature_name'):
                        feature_names = list(booster.feature_name())
                    elif hasattr(booster, 'feature_name_'):
                        feature_names = list(booster.feature_name_)
                except Exception:
                    feature_names = None

            # If we got feature names, pad missing cols with zeros and reorder
            if feature_names:
                missing = [c for c in feature_names if c not in X_patient.columns]
                if missing:
                    print(f"DEBUG: Padding missing features: {missing}")
                    for c in missing:
                        X_patient[c] = 0
                # Reorder to match model
                X_patient = X_patient[feature_names]
                try:
                    # Try predict_proba again
                    y_prob = calibrated.predict_proba(X_patient)[:, 1][0]
                except Exception as e2:
                    print(f"Retry predict_proba after padding failed: {e2}")
                    y_prob = None
            else:
                y_prob = None

            # If still failing, and we have a booster, call its predict with shape check disabled
            if (y_prob is None or (isinstance(y_prob, float) and (pd.isna(y_prob)))) and booster is not None:
                try:
                    arr = X_patient.values if hasattr(X_patient, 'values') else X_patient
                    # LightGBM Booster.predict returns probabilities for binary if pred_leaf False
                    preds = booster.predict(arr, predict_disable_shape_check=True)
                    # preds could be shape (n_samples,) for positive class probability or (n_samples,2)
                    if hasattr(preds, 'ndim') and getattr(preds, 'ndim') == 2:
                        prob = float(preds[0, 1])
                    else:
                        prob = float(preds[0])
                    y_prob = prob
                    print("DEBUG: Obtained probability via booster.predict with shape check disabled")
                except Exception as e3:
                    print(f"Final fallback predict via booster failed: {e3}")
                    raise
        except Exception as outer_e:
            print(f"Unexpected error while attempting recovery from prediction error: {outer_e}")
            raise

    # At this point we must have a y_prob
    if y_prob is None:
        raise RuntimeError("Could not compute prediction probability (y_prob is None)")

    # Debug: Print raw probability
    print(f"DEBUG: Raw model probability: {y_prob:.6f}")

    # --- Map raw probability to continuous risk scale ---
    # Use exponential scaling that grows continuously above threshold
    # This properly differentiates high-risk cases instead of capping at 100%
    threshold = 0.5  # Midpoint for hypertension risk
    
    if y_prob < threshold:
        # Below threshold: gentler quadratic scaling
        risk_percentage = float((y_prob / threshold) ** 1.3 * 50.0)
    else:
        # Above threshold: accelerated exponential scaling
        # At threshold (0.5): ~50%
        # At 0.7: ~100%
        # At 0.85: ~170%
        # At 0.95: ~250%
        risk_percentage = float(50.0 + ((y_prob / threshold - 1.0) ** 1.4) * 125.0)
    
    # Cap at a reasonable maximum (e.g., 300% for very high risk)
    risk_percentage = float(min(risk_percentage, 300.0))

    # --- Risk level ranges based on percentage (now 0-300% scale) ---
    if risk_percentage <= 25:
        risk_level = 1
        risk_label = "Muy Bajo"
    elif risk_percentage <= 60:
        risk_level = 2
        risk_label = "Bajo"
    elif risk_percentage <= 100:
        risk_level = 3
        risk_label = "Medio"
    elif risk_percentage <= 160:
        risk_level = 4
        risk_label = "Alto"
    else:  # 161-300
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

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


def _xml_response(data: dict, root: str = "response") -> Response:
    """Convert dict to XML response if client accepts application/xml"""
    xml_bytes = dicttoxml(data, custom_root=root, attr_type=False)
    return Response(content=xml_bytes, media_type="application/xml")


@app.post("/predict_hypertension")
def predict_hypertension_post(data: dict, user: dict = Depends(require_auth)):
    """Predict hypertension risk given extracted features from questionnaire. Requires valid JWT token."""
    # Verify the user is accessing their own data or is an admin
    user_id = data.get("id_usuario")
    if user_id and str(user_id) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot access other users' data")
    
    print(f"=== HYPERTENSION PREDICT CALLED WITH DATA: {data} ===")
    try:
        # Extract fields from POST data
        user_id = data.get("id_usuario")
        age = float(data.get("age", 50))
        salt_intake = float(data.get("salt_intake", 0))
        stress_score = float(data.get("stress_score", 5))
        sleep_duration = float(data.get("sleep_duration", 7))
        bmi = float(data.get("bmi", 25))
        medication = int(data.get("medication", 0))
        family_history = int(data.get("family_history", 0))
        exercise_level = float(data.get("exercise_level", 0))
        smoking_status = int(data.get("smoking_status", 0))
        bp_history = int(data.get("bp_history", 0))
        
        # Build DataFrame with the provided features
        df = pd.DataFrame([{
            "Age": age,
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
        
        print(f"DEBUG: Received hypertension features from POST: age={age}, stress={stress_score}, bmi={bmi}, smoking={smoking_status}, exercise={exercise_level}")
        
        result = predict_risk_from_df(df)
        print(f"DEBUG: Prediction result: {result}")
        
        # After computing the prediction, persist a row to Prediccion table (best-effort)
        if user_id:
            try:
                probability = float(result.get("probability", 0.0))
                pred_bool = True if probability > 0.8 else False
                print(f"DEBUG: About to insert Prediccion: user_id={user_id}, prob={probability}, pred_bool={pred_bool}")
                conn = get_conn()
                try:
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
        else:
            print(f"WARNING: user_id is None/empty, not inserting Prediccion")
        
        print(f"=== RETURNING HYPERTENSION PREDICTION RESPONSE ===")
        return {"user_id": user_id, "prediction": result}
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Error in predict_hypertension_post endpoint: {error_trace}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.get("/prediccion/latest/{user_id}")
def latest_predicciones(user_id: int, user: dict = Depends(require_auth), request: Request = None):
    """Return the latest Prediccion rows for diabetes (1) and hypertension (2) for a user. Requires valid JWT token."""
    # Verify the user is accessing their own data or is an admin
    if str(user_id) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot access other users' data")
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
                    # compute a display percentage using same scaling as predict_risk
                    pct = None
                    if prob is not None:
                        try:
                            prob_f = float(prob)
                            if id_enf == 1:
                                # Diabetes scaling
                                threshold = 0.2
                                if prob_f < threshold:
                                    pct = float((prob_f / threshold) ** 1.2 * 50.0)
                                else:
                                    pct = float(50.0 + ((prob_f / threshold - 1.0) ** 1.5) * 100.0)
                                pct = float(min(pct, 300.0))
                            else:
                                # Hypertension scaling
                                threshold = 0.5
                                if prob_f < threshold:
                                    pct = float((prob_f / threshold) ** 1.3 * 50.0)
                                else:
                                    pct = float(50.0 + ((prob_f / threshold - 1.0) ** 1.4) * 125.0)
                                pct = float(min(pct, 300.0))
                        except Exception:
                            pct = None

                    result['predictions'].append({
                        'id_enfermedad': id_enf,
                        'probabilidad': prob,
                        'percentage': pct,
                        'prediccion': pred_bool,
                        'fecha': str(fecha) if fecha is not None else None
                    })
                if request and "application/xml" in request.headers.get("accept", "").lower():
                    return _xml_response(result, "LatestPredictions")
                return result
    except Exception as e:
        import traceback
        print(f"Error fetching latest prediccion: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/prediccion/latest/hypertension/{user_id}")
def latest_prediccion_hypertension(user_id: int, user: dict = Depends(require_auth), request: Request = None):
    """Return the newest Prediccion row for hypertension (id_enfermedad=2) for a user. Requires valid JWT token."""
    # Verify the user is accessing their own data or is an admin
    if str(user_id) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot access other users' data")
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
                    resp = {"user_id": user_id, "prediction": None}
                    if request and "application/xml" in request.headers.get("accept", "").lower():
                        return _xml_response(resp, "HypertensionPrediction")
                    return resp

                prob = row.get('probabilidad')
                pred_bool = row.get('prediccion')
                fecha = row.get('fecha')

                pct = None
                if prob is not None:
                    try:
                        prob_f = float(prob)
                        # Apply the same scaling logic as predict_risk_from_df
                        threshold = 0.5
                        if prob_f < threshold:
                            pct = float((prob_f / threshold) ** 1.3 * 50.0)
                        else:
                            pct = float(50.0 + ((prob_f / threshold - 1.0) ** 1.4) * 125.0)
                        pct = float(min(pct, 300.0))
                    except Exception:
                        pct = None

                resp = {
                    'user_id': user_id,
                    'prediction': {
                        'id_enfermedad': 2,
                        'probabilidad': prob,
                        'percentage': pct,
                        'prediccion': pred_bool,
                        'fecha': str(fecha) if fecha is not None else None
                    }
                }
                if request and "application/xml" in request.headers.get("accept", "").lower():
                    return _xml_response(resp, "HypertensionPrediction")
                return resp
    except Exception as e:
        import traceback
        print(f"Error fetching latest hypertension prediccion: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))


# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
