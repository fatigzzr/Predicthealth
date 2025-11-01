# services/health_service/main.py
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from services.shared.db import get_conn
import traceback
from typing import Optional

APP_PORT = int(os.getenv("HEALTH_PORT", "8004"))

app = FastAPI(title="Health Service", version="0.1.0")

# ---- Pydantic model ----
class HealthEntry(BaseModel):
    id_usuario: int
    frutas: Optional[str] = ""
    verduras: Optional[str] = ""
    sal: Optional[str] = ""
    fuma: Optional[str] = ""
    alcohol: Optional[str] = ""
    movilidad: Optional[str] = ""
    horas_sueno: Optional[str] = ""
    nivel_estres: Optional[str] = ""
    salud_mental: Optional[str] = ""
    actividad_fisica: Optional[str] = ""
    actividad_frecuente: Optional[str] = ""
    salud_fisica: Optional[str] = ""
    fecha: Optional[str] = None  # optional client-supplied timestamp

# ---- Mapping JSON keys to pregunta IDs ----
KEY_TO_PREGUNTA_ID = {
    "frutas": 1,
    "verduras": 2,
    "sal": 3,
    "fuma": 4,
    "alcohol": 5,
    "movilidad": 6,
    "horas_sueno": 7,
    "nivel_estres": 8,
    "salud_mental": 9,
    "actividad_fisica": 10,
    "actividad_frecuente": 11,
    "salud_fisica": 12,
}

# ---- Endpoint ----
@app.post("/estilo_vida")
async def create_health_entries(entry: HealthEntry):
    fecha = entry.fecha or datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                for key, id_pregunta in KEY_TO_PREGUNTA_ID.items():
                    valor = getattr(entry, key, "")
                    cur.execute(
                        """
                        INSERT INTO respuesta_estilo_vida
                        (id_usuario, id_pregunta, valor, fecha)
                        VALUES (%s, %s, %s, %s)
                        """,
                        (
                            entry.id_usuario,
                            id_pregunta,
                            valor,
                            fecha
                        )
                    )
                conn.commit()
    except Exception as e:
        tb = traceback.format_exc()
        print("=== DATABASE ERROR ===")
        print(tb)
        print("======================")
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

    return {"status": "ok", "inserted_for_usuario": entry.id_usuario}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
