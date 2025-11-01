# services/paciente_service/main.py
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import traceback
from services.shared.db import get_conn
from typing import Optional

# ---- Config ----
APP_PORT = int(os.getenv("PACIENTE_PORT", "8003"))

# ---- FastAPI app ----
app = FastAPI(title="Paciente Service", version="0.1.0")

# ---- Pydantic model ----
class Paciente(BaseModel):
    id_usuario: int
    nombre: str
    apellido: str
    fecha_nacimiento: str  # "YYYY-MM-DD"
    sexo: str
    fecha: Optional[str] = None

# ---- Endpoint ----
@app.post("/paciente")
async def create_paciente(paciente: Paciente):
    fecha = paciente.fecha or datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO "paciente" 
                    (id_usuario, nombre, apellido, fecha_nacimiento, sexo, fecha)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id_datos
                    """,
                    (
                        paciente.id_usuario,
                        paciente.nombre,
                        paciente.apellido,
                        paciente.fecha_nacimiento,
                        paciente.sexo,
                        fecha
                    )
                )
                inserted = cur.fetchone()
                conn.commit()
    except Exception as e:
        tb = traceback.format_exc()
        print("=== DATABASE ERROR ===")
        print(tb)
        print("======================")
        raise HTTPException(status_code=500, detail=f"DB error: {e}")


    if not inserted:
        raise HTTPException(status_code=500, detail="Insert succeeded but returned no id_datos")

    return {"status": "ok", "id_datos": inserted["id_datos"]}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
