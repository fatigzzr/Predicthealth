import os
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from services.shared.db import get_conn
from services.shared.auth import require_auth
from psycopg2.extras import Json
import traceback

app = FastAPI(title="Data Service - Guardar Historial", version="0.1")
APP_PORT = int(os.getenv("DATA_SERVICE_PORT", "8010"))

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


@app.post("/guardar_historial")
def guardar_historial(data: dict, user: dict = Depends(require_auth)):
    """Receive a full patient payload and call the stored procedure sp_guardar_paciente_historial. Requires valid JWT token.

    Expected fields in `data` (best-effort tolerant):
      - id_usuario (int or string)
      - nombre, apellido, sexo, fecha_nacimiento
      - diabetes (bool), hipertension (bool)
      - colesterol, colesterol_alto, bmi, presion, salud_general, acv, problemas_corazon
      - medicamentos: array of strings
      - estilo_vida: JSON object
    """
    # Verify the user is accessing their own data or is an admin
    uid = data.get("id_usuario")
    if uid and str(uid) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot modify other users' data")
    try:
        # Normalize fields and provide safe defaults
        uid = data.get("id_usuario")
        try:
            p_id_usuario = int(uid) if uid is not None and str(uid).strip() != "" else None
        except Exception:
            p_id_usuario = None

        p_nombre = data.get("nombre", "")
        p_apellido = data.get("apellido", "")
        p_sexo = data.get("sexo", None)
        p_fecha_nacimiento = data.get("fecha_nacimiento", None)

        p_diabetes = bool(data.get("diabetes", False))
        p_hipertension = bool(data.get("hipertension", False))
        p_colesterol = data.get("colesterol", "")
        p_colesterol_alto = data.get("colesterol_alto", "")
        try:
            p_bmi = float(data.get("bmi", 0)) if data.get("bmi", None) not in (None, "") else None
        except Exception:
            p_bmi = None
        p_presion = data.get("presion", "")
        p_salud_general = data.get("salud_general", "")
        p_acv = data.get("acv", "")
        p_problemas_corazon = data.get("problemas_corazon", "")

        meds = data.get("medicamentos", None)
        # Accept JSON array or comma-separated string
        if meds is None:
            p_medicamentos = []
        elif isinstance(meds, list):
            p_medicamentos = [str(x) for x in meds]
        else:
            # try parse comma-separated
            s = str(meds)
            try:
                # if it's a JSON array string, attempt to parse
                import json
                parsed = json.loads(s)
                if isinstance(parsed, list):
                    p_medicamentos = [str(x) for x in parsed]
                else:
                    p_medicamentos = [x.strip() for x in s.split(",") if x.strip()]
            except Exception:
                p_medicamentos = [x.strip() for x in s.split(",") if x.strip()]

        estilo = data.get("estilo_vida", {})
        
        # Map Java app keys to database stored procedure keys
        # Java sends: frutas, verduras, fuma, alcohol, movilidad, actividad_frecuente
        # DB expects: consumeFrutas, consumeVerduras, fuma, alcoholExceso, dificultadCaminar, actividad3Veces
        key_mapping = {
            "frutas": "consumeFrutas",
            "verduras": "consumeVerduras",
            "sal": "salDiaria",
            "fuma": "fuma",  # same key
            "alcohol": "alcoholExceso",
            "movilidad": "dificultadCaminar",
            "horas_sueno": "horasSueno",
            "nivel_estres": "nivelEstres",
            "salud_mental": "diasSaludMentalMala",
            "actividad_fisica": "nivelActividad",
            "actividad_frecuente": "actividad3Veces",
            "salud_fisica": "diasSaludFisicaMala"
        }
        
        # Transform estilo_vida keys
        mapped_estilo = {}
        for java_key, db_key in key_mapping.items():
            if java_key in estilo:
                mapped_estilo[db_key] = estilo[java_key]
        
        # Keep any unmapped keys as-is (for future compatibility)
        for key, value in estilo.items():
            if key not in key_mapping:
                mapped_estilo[key] = value

        with get_conn() as conn:
            with conn.cursor() as cur:
                # Prepare CALL statement with proper parameter binding (no inline casting)
                # psycopg2 will handle the None to NULL conversions and type inference
                # 16 parameters total for sp_guardar_paciente_historial
                sql = (
                    "CALL sp_guardar_paciente_historial(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                )

                params = [
                    p_id_usuario,
                    p_nombre,
                    p_apellido,
                    p_sexo,
                    p_fecha_nacimiento,
                    p_diabetes,
                    p_hipertension,
                    p_colesterol,
                    p_colesterol_alto,
                    p_bmi,
                    p_presion,
                    p_salud_general,
                    p_acv,
                    p_problemas_corazon,
                    p_medicamentos if p_medicamentos else None,  # psycopg2 converts list to text[]
                    Json(mapped_estilo)  # Use mapped keys instead of raw estilo
                ]

                # Execute the CALL. psycopg2 will map Python None to SQL NULL and list to text[].
                cur.execute(sql, params)
                conn.commit()

        return {"status": "ok"}

    except Exception as e:
        tb = traceback.format_exc()
        print("=== DATA SERVICE ERROR ===")
        print(tb)
        print("==========================")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
