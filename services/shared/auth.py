import os
from typing import Optional
import time

import jwt
import redis


JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = os.getenv("JWT_ALG", "HS256")
JWT_AUD = os.getenv("JWT_AUD", "predicthealth")

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")


def get_redis() -> redis.Redis:
    return redis.from_url(REDIS_URL, decode_responses=True)


def verify_jwt_and_jti(token: str, required_aud: Optional[str] = None) -> dict:
    claims = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG], audience=required_aud or JWT_AUD, options={"verify_aud": bool(required_aud or JWT_AUD)})
    jti = claims.get("jti")
    if not jti:
        raise jwt.InvalidTokenError("missing jti")
    r = get_redis()
    if r.get(f"auth:jti:{jti}") != "1":
        raise jwt.InvalidTokenError("jti not allowed or revoked")
    return claims


def allowlist_jti(jti: str, exp_ts: int) -> None:
    r = get_redis()
    ttl = max(1, exp_ts - int(time.time()))
    r.set(f"auth:jti:{jti}", "1", ex=ttl)


def revoke_jti(jti: str) -> None:
    r = get_redis()
    r.delete(f"auth:jti:{jti}")


