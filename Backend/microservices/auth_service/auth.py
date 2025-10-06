# auth_service/auth.py
import jwt, redis, datetime
from fastapi import HTTPException

SECRET_KEY = "supersecret"
REDIS = redis.Redis(host="localhost", port=6379, db=0)

def create_jwt(email: str):
    payload = {
        "sub": email,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
    REDIS.set(token, email, ex=3600)
    return token

def verify_jwt(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        if REDIS.get(token) is None:
            raise HTTPException(status_code=401, detail="Invalid Token")
        return payload["sub"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid Token")
