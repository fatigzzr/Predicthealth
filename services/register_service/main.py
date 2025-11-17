# register_service/main.py
import os
from dotenv import load_dotenv, find_dotenv
from fastapi import FastAPI, HTTPException, Body, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncpg
from passlib.hash import pbkdf2_sha256
from dicttoxml import dicttoxml

# ---- Config ----
load_dotenv(find_dotenv(), override=False)
APP_PORT = int(os.getenv("REGISTER_PORT", "8002"))

# Prefer DATABASE_URL; otherwise construct from DB_* variables
DB_URL = os.getenv("DATABASE_URL")
if not DB_URL or DB_URL.strip() == "":
    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    missing = [k for k,v in {
        'DB_HOST': db_host,
        'DB_NAME': db_name,
        'DB_USER': db_user,
        'DB_PASSWORD': db_password
    }.items() if not v]
    if missing:
        raise RuntimeError(f"Missing required DB env vars for register_service: {', '.join(missing)}")
    DB_URL = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

# ---- FastAPI app ----
app = FastAPI(title="Register Service", docs_url="/docs", redoc_url="/redoc", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)

# ---- Pydantic Models ----
class UserRegister(BaseModel):
    id_rol: int
    email: str
    contraseña: str

class UserRegisterResponse(BaseModel):
    id_usuario: int
    email: str

# ---- Helpers ----
def _xml(data: dict, root: str) -> Response:
    xml_bytes = dicttoxml(data, custom_root=root, attr_type=False)
    return Response(content=xml_bytes, media_type="application/xml")

# ---- Database ----
@app.on_event("startup")
async def startup():
    app.state.db = await asyncpg.connect(DB_URL)

@app.on_event("shutdown")
async def shutdown():
    await app.state.db.close()

# ---- Endpoints ----
@app.post("/register", response_model=UserRegisterResponse)
async def register_user(data: UserRegister = Body(..., example={
    "id_rol": 1,
    "email": "user@example.com",
    "contraseña": "your_password_here"
}), request: Request = None):
    # Hash password
    hashed_password = pbkdf2_sha256.hash(data.contraseña)

    query = """
        INSERT INTO usuario (id_rol, email, contrasena_hash)
        VALUES ($1, $2, $3)
        RETURNING id_usuario;
    """
    try:
        row = await app.state.db.fetchrow(query, data.id_rol, data.email, hashed_password)
    except asyncpg.exceptions.UniqueViolationError:
        raise HTTPException(status_code=400, detail="User already exists")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")

    resp = {"id_usuario": row["id_usuario"], "email": data.email}
    content_type = request.headers.get("Content-Type", "") if request else ""
    if "xml" in content_type:
        return _xml(resp, "UserRegisterResponse")
    return resp

@app.get("/register/health")
async def health_check():
    try:
        await app.state.db.execute("SELECT 1;")
        return {"status": "ok", "db": "reachable"}
    except Exception as e:
        return {"status": "error", "db": "unreachable", "detail": str(e)}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
