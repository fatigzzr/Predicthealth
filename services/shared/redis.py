# services/shared/redis.py

import os
import redis
import json
from datetime import datetime, timezone

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
REDIS_DB = int(os.getenv("REDIS_DB", "0"))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)

ALLOWLIST_PREFIX = "jwt_allow:"
REVOKED_PREFIX = "jwt_revoke:"

def allowlist_jti(jti: str, exp_ts: int):
    """
    Store JWT JTI in allowlist with expiry timestamp.
    """
    key = f"{ALLOWLIST_PREFIX}{jti}"
    now_ts = int(datetime.now(timezone.utc).timestamp())
    ttl = max(exp_ts - now_ts, 0)
    r.set(key, json.dumps({"jti": jti, "exp": exp_ts}), ex=ttl)

def revoke_jti(jti: str):
    """
    Mark a JWT as revoked.
    """
    allow_key = f"{ALLOWLIST_PREFIX}{jti}"
    revoke_key = f"{REVOKED_PREFIX}{jti}"
    data = r.get(allow_key)
    if data:
        r.set(revoke_key, data)
        r.delete(allow_key)

def is_jti_revoked(jti: str) -> bool:
    """
    Check if JTI is revoked.
    """
    key = f"{REVOKED_PREFIX}{jti}"
    return r.exists(key) > 0

def is_jti_allowed(jti: str) -> bool:
    """
    Check if JTI is in allowlist and not revoked.
    """
    if is_jti_revoked(jti):
        return False
    key = f"{ALLOWLIST_PREFIX}{jti}"
    return r.exists(key) > 0
