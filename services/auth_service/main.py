# services/auth_service/main.py

import os
import uuid
from datetime import datetime, timedelta

from fastapi import FastAPI, Request, Response, HTTPException, Header, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import jwt
from dicttoxml import dicttoxml
import xmltodict

from services.shared.redis import allowlist_jti, revoke_jti, is_jti_allowed

from passlib.hash import pbkdf2_sha256
from services.shared.db import get_conn 

# ---- Config ----
APP_PORT = int(os.getenv("AUTH_PORT", "8001"))
JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = os.getenv("JWT_ALG", "HS256")
JWT_AUD = os.getenv("JWT_AUD", "predicthealth")
ACCESS_TTL_MIN = int(os.getenv("ACCESS_TTL_MIN", "15"))

# ---- FastAPI app ----
app = FastAPI(title="Auth Service", docs_url="/docs", redoc_url="/redoc", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)

# ---- Pydantic Models ----
class LoginRequest(BaseModel):
    username: str
    password: str

class LoginResponseUser(BaseModel):
    id: str
    email: str
    roleId: int

class LoginResponse(BaseModel):
    token: str
    expiresAt: str
    user: LoginResponseUser

# ---- Helpers ----
def _xml(data: dict, root: str) -> Response:
    xml_bytes = dicttoxml(data, custom_root=root, attr_type=False)
    return Response(content=xml_bytes, media_type="application/xml")

def _issue_token(user_id: str, email: str, role_id: int) -> dict:
    jti = str(uuid.uuid4())
    now = datetime.utcnow()
    exp = now + timedelta(minutes=ACCESS_TTL_MIN)
    payload = {
        "sub": user_id,
        "email": email,
        "roleId": role_id,
        "aud": JWT_AUD,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "jti": jti,
    }
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALG)
    allowlist_jti(jti, int(exp.timestamp()))
    return {
        "token": token,
        "expiresAt": exp.isoformat() + "Z",
        "user": {"id": user_id, "email": email, "roleId": role_id}
    }

def verify_jwt_and_jti(token: str) -> dict:
    try:
        decoded = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG], audience=JWT_AUD)
    except Exception:
        raise HTTPException(status_code=401, detail="invalid_token")
    jti = decoded.get("jti")
    if not jti or not is_jti_allowed(jti):
        raise HTTPException(status_code=401, detail="token_revoked_or_invalid")
    return decoded

# ---- Endpoints ----

@app.get("/auth/health")
async def health():
    return {"status": "ok"}  # Swagger-friendly JSON

@app.post("/auth/login", response_model=LoginResponse)
async def login(
    data: LoginRequest = Body(..., example={"username": "user@example.com", "password": "secret"}),
    req: Request = None
):
    username = data.username
    password = data.password

    if not username or not password:
        raise HTTPException(status_code=400, detail="email_and_password_required")

    # lookup user in Postgres
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # fix table/column names with quotes if needed
                cur.execute(
                    'SELECT id_usuario, email, contrasena_hash, id_rol FROM usuario WHERE email = %s',
                    (username,)
                )
                row = cur.fetchone()
    except Exception as e:
        # include the exception message for debugging
        raise HTTPException(status_code=500, detail=f"db_error: {str(e)}")

    if not row:
        raise HTTPException(status_code=401, detail="invalid_credentials")

    # using dict access if RealDictCursor
    if isinstance(row, dict):
        user_id = str(row['id_usuario'])
        email = row['email']
        stored_hash = row['contrasena_hash']
        role_id = row['id_rol']
    else:
        user_id = str(row[0])
        email = row[1]
        stored_hash = row[2]
        role_id = row[3]

    # bcrypt verify
    try:
        if not pbkdf2_sha256.verify(password, stored_hash):
            raise HTTPException(status_code=401, detail="invalid_credentials")
    except ValueError:
        raise HTTPException(status_code=500, detail="password_hash_invalid")

    # success -> issue token
    resp = _issue_token(user_id, email, role_id)

    # Return XML for gateway or JSON for direct clients
    content_type = req.headers.get("content-type", "") if req else ""
    if "xml" in content_type:
        return _xml(resp, "AuthResponse")
    return resp



@app.get("/auth/me")
async def me(authorization: str = Header(..., description="Bearer token")):
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = authorization.split()[1]
    claims = verify_jwt_and_jti(token)
    return claims  # JSON for Swagger

@app.post("/auth/logout")
async def logout(authorization: str = Header(..., description="Bearer token")):
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = authorization.split()[1]
    try:
        claims = verify_jwt_and_jti(token)
        jti = claims.get("jti")
        if jti:
            revoke_jti(jti)
    except Exception:
        pass
    return {"status": "ok"}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
