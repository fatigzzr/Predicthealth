# services/paciente_service/main.py
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException, Body, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import traceback
from services.shared.db import get_conn
from services.shared.auth import require_auth
from typing import Optional

# ---- Config ----
APP_PORT = int(os.getenv("PACIENTE_PORT", "8003"))

# ---- FastAPI app ----
app = FastAPI(title="Paciente Service", version="0.1.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)

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
async def create_paciente(paciente: Paciente, user: dict = Depends(require_auth)):
    """Create or update patient data. Requires valid JWT token."""
    # Verify the user is accessing their own data or is an admin
    if str(paciente.id_usuario) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot modify other users' data")
    
    fecha = paciente.fecha or datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Debug: Print incoming data
    print(f"DEBUG: Received paciente data:")
    print(f"  id_usuario={paciente.id_usuario}")
    print(f"  nombre='{paciente.nombre}'")
    print(f"  apellido='{paciente.apellido}'")
    print(f"  fecha_nacimiento='{paciente.fecha_nacimiento}'")
    print(f"  sexo='{paciente.sexo}' (length={len(paciente.sexo)}, repr={repr(paciente.sexo)})")
    print(f"  fecha='{fecha}'")

    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO paciente
                        (id_usuario, nombre, apellido, fecha_nacimiento, sexo, fecha)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON CONFLICT (id_usuario) DO UPDATE
                    SET
                        nombre = EXCLUDED.nombre,
                        apellido = EXCLUDED.apellido,
                        fecha_nacimiento = EXCLUDED.fecha_nacimiento,
                        sexo = EXCLUDED.sexo,
                        fecha = EXCLUDED.fecha
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


@app.get("/paciente/{user_id}")
def get_paciente(user_id: int):
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT id_datos, id_usuario, nombre, apellido, fecha_nacimiento, sexo, fecha
                    FROM Paciente
                    WHERE id_usuario = %s
                    ORDER BY fecha DESC
                    LIMIT 1
                    """,
                    (user_id,)
                )
                row = cur.fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Paciente not found")
                return dict(row)
    except HTTPException:
        raise
    except Exception as e:
        tb = traceback.format_exc()
        print("=== DATABASE ERROR (get paciente) ===")
        print(tb)
        print("======================")
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
