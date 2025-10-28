import os
import uuid
import time
from datetime import datetime, timedelta
from typing import Optional

from fastapi import FastAPI, Request, Response, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import jwt
from dicttoxml import dicttoxml
import xmltodict

from services.shared.auth import allowlist_jti, revoke_jti, verify_jwt_and_jti


APP_PORT = int(os.getenv("AUTH_PORT", "8001"))
JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = os.getenv("JWT_ALG", "HS256")
JWT_AUD = os.getenv("JWT_AUD", "predicthealth")
ACCESS_TTL_MIN = int(os.getenv("ACCESS_TTL_MIN", "15"))


app = FastAPI(title="Auth Service", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


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
    return {"token": token, "expiresAt": exp.isoformat() + "Z", "user": {"id": user_id, "email": email, "roleId": role_id}}


@app.get("/auth/health")
async def health():
    return _xml({"status": "ok"}, "Health")


@app.post("/auth/login")
async def login(req: Request):
    # Expect XML via gateway; but support JSON for direct tests
    content_type = req.headers.get("content-type", "")
    if "xml" in content_type:
        body = await req.body()
        payload = xmltodict.parse(body.decode())
        root = next(iter(payload.values())) if payload else {}
        username = root.get("username")
        password = root.get("password")
    else:
        data = await req.json()
        username = data.get("username") or data.get("email")
        password = data.get("password")

    if not username or not password:
        raise HTTPException(status_code=400, detail="email_and_password_required")

    # TODO: Replace with PostgreSQL check (sp_login_staff). For now accept any non-empty.
    # Demo user mapping
    user_id = "1"
    role_id = 1
    resp = _issue_token(user_id, username, role_id)
    return _xml(resp, "AuthResponse")


@app.get("/auth/me")
async def me(req: Request):
    auth = req.headers.get("authorization") or req.headers.get("Authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = auth.split()[1]
    claims = verify_jwt_and_jti(token)
    return _xml({
        "id": claims.get("sub"),
        "email": claims.get("email"),
        "roleId": claims.get("roleId"),
    }, "User")


@app.post("/auth/logout")
async def logout(req: Request):
    auth = req.headers.get("authorization") or req.headers.get("Authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = auth.split()[1]
    try:
        claims = verify_jwt_and_jti(token)
        jti = claims.get("jti")
        if jti:
            revoke_jti(jti)
    except Exception:
        pass
    return _xml({"status": "ok"}, "LogoutResponse")


def create_app():
    return app


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)


