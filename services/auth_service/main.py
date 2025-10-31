# services/auth_service/main.py
import os
import uuid
from datetime import datetime, timedelta, timezone

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
REFRESH_TTL_DAYS = int(os.getenv("REFRESH_TTL_DAYS", "7"))

# ---- FastAPI app ----
app = FastAPI(title="Auth Service", docs_url="/docs", redoc_url="/redoc", version="0.2.0")
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

class TokenResponseUser(BaseModel):
    id: str
    email: str
    roleId: int

class LoginResponse(BaseModel):
    access_token: str
    access_expiresAt: str
    refresh_token: str
    refresh_expiresAt: str
    user: TokenResponseUser

class RefreshRequest(BaseModel):
    refresh_token: str

# ---- Helpers ----
def _xml(data: dict, root: str) -> Response:
    xml_bytes = dicttoxml(data, custom_root=root, attr_type=False)
    return Response(content=xml_bytes, media_type="application/xml")

def _issue_tokens(user_id: str, email: str, role_id: int) -> dict:
    now = datetime.now(timezone.utc)
    
    access_exp = now + timedelta(minutes=ACCESS_TTL_MIN)
    access_jti = str(uuid.uuid4())
    access_payload = {
        "sub": user_id,
        "email": email,
        "roleId": role_id,
        "aud": JWT_AUD,
        "iat": int(now.timestamp()),
        "exp": int(access_exp.timestamp()),
        "jti": access_jti,
        "type": "access"
    }
    access_token = jwt.encode(access_payload, JWT_SECRET, algorithm=JWT_ALG)
    allowlist_jti(access_jti, int(access_exp.timestamp()))
    
    refresh_exp = now + timedelta(days=REFRESH_TTL_DAYS)
    refresh_jti = str(uuid.uuid4())
    refresh_payload = {
        "sub": user_id,
        "email": email,
        "roleId": role_id,
        "aud": JWT_AUD,
        "iat": int(now.timestamp()),
        "exp": int(refresh_exp.timestamp()),
        "jti": refresh_jti,
        "type": "refresh"
    }
    refresh_token = jwt.encode(refresh_payload, JWT_SECRET, algorithm=JWT_ALG)
    allowlist_jti(refresh_jti, int(refresh_exp.timestamp()))
    
    return {
        "access_token": access_token,
        "access_expiresAt": access_exp.isoformat(),
        "refresh_token": refresh_token,
        "refresh_expiresAt": refresh_exp.isoformat(),
        "user": {"id": user_id, "email": email, "roleId": role_id}
    }

def verify_jwt_and_jti(token: str, expected_type: str = "access") -> dict:
    try:
        decoded = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[JWT_ALG],
            audience=JWT_AUD,
            leeway=10
        )
    except Exception:
        raise HTTPException(status_code=401, detail="invalid_token")
    if decoded.get("type") != expected_type:
        raise HTTPException(status_code=400, detail=f"not_a_{expected_type}_token")
    jti = decoded.get("jti")
    if not jti or not is_jti_allowed(jti):
        raise HTTPException(status_code=401, detail="token_revoked_or_invalid")
    return decoded

# ---- Endpoints ----
@app.get("/auth/health")
async def health():
    return {"status": "ok"}

@app.post("/auth/login", response_model=LoginResponse)
async def login(
    data: LoginRequest = Body(..., example={"username": "user@example.com", "password": "secret"}),
    req: Request = None
):
    username = data.username
    password = data.password

    if not username or not password:
        raise HTTPException(status_code=400, detail="email_and_password_required")

    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    'SELECT id_usuario, email, contrasena_hash, id_rol FROM usuario WHERE email = %s',
                    (username,)
                )
                row = cur.fetchone()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"db_error: {str(e)}")

    if not row:
        raise HTTPException(status_code=401, detail="invalid_credentials")

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

    if not pbkdf2_sha256.verify(password, stored_hash):
        raise HTTPException(status_code=401, detail="invalid_credentials")

    resp = _issue_tokens(user_id, email, role_id)
    content_type = req.headers.get("content-type", "") if req else ""
    if "xml" in content_type:
        return _xml(resp, "AuthResponse")
    return resp

@app.post("/auth/refresh", response_model=LoginResponse)
async def refresh_token(data: RefreshRequest):
    token = data.refresh_token
    if not token:
        raise HTTPException(status_code=400, detail="refresh_token_required")

    decoded = verify_jwt_and_jti(token, expected_type="refresh")
    revoke_jti(decoded.get("jti"))

    user_id = decoded["sub"]
    email = decoded["email"]
    role_id = decoded["roleId"]
    return _issue_tokens(user_id, email, role_id)

@app.get("/auth/me")
async def me(authorization: str = Header(..., description="Bearer token")):
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = authorization.split()[1]
    claims = verify_jwt_and_jti(token, expected_type="access")
    return claims

@app.post("/auth/logout")
async def logout(authorization: str = Header(..., description="Bearer token")):
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = authorization.split()[1]
    try:
        claims = verify_jwt_and_jti(token)
        revoke_jti(claims.get("jti"))
    except Exception:
        pass
    return {"status": "ok"}

# ---- Run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)
