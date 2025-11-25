# services/shared/auth.py

import os
from dotenv import load_dotenv, find_dotenv
import uuid
import time
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException, Header, Depends
from typing import Optional
from .redis import allowlist_jti, revoke_jti, is_jti_allowed

# Load .env so JWT_* are available when importing this module
load_dotenv(find_dotenv(), override=False)

# JWT configuration
JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALG = os.getenv("JWT_ALG", "HS256")
JWT_AUD = os.getenv("JWT_AUD", "predicthealth")
ACCESS_TTL_MIN = int(os.getenv("ACCESS_TTL_MIN", "15"))

if not JWT_SECRET or str(JWT_SECRET).strip() == "":
    raise RuntimeError("JWT_SECRET is required; set it in your .env")


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


# FastAPI dependency for JWT authentication
async def require_auth(authorization: Optional[str] = Header(None)) -> dict:
    """
    FastAPI dependency that requires a valid JWT token.
    Returns the decoded payload with user information.
    
    Usage in endpoints:
        @app.get("/protected")
        async def protected_endpoint(user: dict = Depends(require_auth)):
            user_id = user["sub"]
            email = user["email"]
            role_id = user["roleId"]
            ...
    """
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization header")
    
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header format. Expected: Bearer <token>")
    
    try:
        token = authorization.split()[1]
    except IndexError:
        raise HTTPException(status_code=401, detail="Invalid authorization header format")
    
    # Verify and decode the token
    try:
        payload = verify_jwt_and_jti(token)
        return payload
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token validation failed: {str(e)}")
