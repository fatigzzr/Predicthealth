# register_service/main.py
from fastapi import FastAPI, Request, HTTPException
from pydantic import BaseModel
import asyncpg
import xmltodict
import os

app = FastAPI()

DB_URL = os.getenv("DATABASE_URL", "postgresql://predicthealth_user:password@localhost/predicthealth")

# Pydantic model for JSON
class UserRegister(BaseModel):
    id_rol: int
    email: str
    contraseña: str

@app.on_event("startup")
async def startup():
    app.state.db = await asyncpg.connect(DB_URL)

@app.on_event("shutdown")
async def shutdown():
    await app.state.db.close()

@app.post("/register")
async def register_user(request: Request):
    content_type = request.headers.get("Content-Type", "")
    if "application/json" in content_type:
        data = await request.json()
    elif "application/xml" in content_type:
        xml = await request.body()
        data = xmltodict.parse(xml)["user"]  # assume root element <user>
        # Convert types
        data = {k: int(v) if k == "id_rol" else str(v) for k, v in data.items()}
    else:
        raise HTTPException(status_code=415, detail="Unsupported Media Type")

    query = """
        INSERT INTO usuario (id_rol, email, contraseña_hash)
        VALUES ($1, $2, crypt($3, gen_salt('bf')))
        RETURNING id_usuario;
    """
    row = await app.state.db.fetchrow(query, data["id_rol"], data["email"], data["contraseña"])
    return {"id_usuario": row["id_usuario"], "email": data["email"]}

# Health endpoint
@app.get("/health")
async def health_check():
    try:
        await app.state.db.execute("SELECT 1;")
        return {"status": "ok", "db": "reachable"}
    except Exception as e:
        return {"status": "error", "db": "unreachable", "detail": str(e)}