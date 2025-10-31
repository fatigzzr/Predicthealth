# services/paciente_service/main.py
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor

# ---- Config ----
DB_HOST = os.getenv("PG_HOST", "localhost")
DB_PORT = int(os.getenv("PG_PORT", "5432"))
DB_NAME = os.getenv("PG_DB", "predicthealth")
DB_USER = os.getenv("PG_USER", "postgres")
DB_PASS = os.getenv("PG_PASS", "postgres")
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

# ---- DB helper ----
def get_conn():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        cursor_factory=RealDictCursor
    )

# ---- Endpoint ----
@app.post("/paciente")
async def create_paciente(paciente: Paciente):
    fecha = datetime.now().strftime("%Y-%m-%d %H:%M:%S")  # server-generated

    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO "Paciente" 
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
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

    return {"status": "ok", "id_datos": inserted["id_datos"]}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
