# services/shared/auth.py

import os
import uuid
import time
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException
from .redis import allowlist_jti, revoke_jti, is_jti_allowed

# JWT configuration
JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = os.getenv("JWT_ALG", "HS256")
JWT_AUD = os.getenv("JWT_AUD", "predicthealth")
ACCESS_TTL_MIN = int(os.getenv("ACCESS_TTL_MIN", "15"))


def issue_jwt(user_id: str, email: str, role_id: int) -> dict:
    """
    Issue a JWT token and store its jti in Redis allowlist.
    """
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


def verify_jwt_and_jti(token: str) -> dict:
    """
    Decode a JWT and verify it is still allowed in Redis.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG], audience=JWT_AUD)
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="invalid_token")

    jti = payload.get("jti")
    if not jti or not is_jti_allowed(jti):
        raise HTTPException(status_code=401, detail="token_revoked_or_invalid")

    return payload


def revoke_jwt(jti: str):
    """
    Revoke a JWT by removing its jti from Redis.
    """
    revoke_jti(jti)
