# register_service/main.py
import os
from dotenv import load_dotenv, find_dotenv
from fastapi import FastAPI, HTTPException, Body, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.hash import pbkdf2_sha256
from dicttoxml import dicttoxml
from services.shared.db import get_conn

# ---- Config ----
load_dotenv(find_dotenv(), override=False)
APP_PORT = int(os.getenv("REGISTER_PORT", "8002"))

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

# No global DB connection; use services.shared.db.get_conn() per request.

# ---- Endpoints ----
@app.post("/register", response_model=UserRegisterResponse)
def register_user(data: UserRegister = Body(..., example={
    "id_rol": 1,
    "email": "user@example.com",
    "contraseña": "your_password_here"
}), request: Request = None):
    # Hash password
    hashed_password = pbkdf2_sha256.hash(data.contraseña)

    sql = (
        """
        INSERT INTO usuario (id_rol, email, contrasena_hash)
        VALUES (%s, %s, %s)
        RETURNING id_usuario;
        """
    )
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, (data.id_rol, data.email, hashed_password))
                row = cur.fetchone()
                user_id = row["id_usuario"] if isinstance(row, dict) else row[0]
    except Exception as e:
        msg = str(e)
        if "23505" in msg or "unique" in msg.lower():
            raise HTTPException(status_code=400, detail="User already exists")
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")

    resp = {"id_usuario": user_id, "email": data.email}
    content_type = request.headers.get("Content-Type", "") if request else ""
    if "xml" in content_type:
        return _xml(resp, "UserRegisterResponse")
    return resp

@app.get("/register/health")
def health_check():
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
        return {"status": "ok", "db": "reachable"}
    except Exception as e:
        return {"status": "error", "db": "unreachable", "detail": str(e)}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
