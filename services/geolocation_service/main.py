import os
from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dicttoxml import dicttoxml
from services.shared.auth import verify_jwt_and_jti

APP_PORT = int(os.getenv("GEO_PORT", "8004"))

app = FastAPI(title="Geolocation Service", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


def _xml(data: dict, root: str) -> Response:
    return Response(content=dicttoxml(data, custom_root=root, attr_type=False), media_type="application/xml")


def _require_bearer(req: Request):
    auth = req.headers.get("authorization") or req.headers.get("Authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing_or_invalid_token")
    token = auth.split()[1]
    verify_jwt_and_jti(token)


@app.get("/geo/users/{user_id}/last-location")
async def last_location(user_id: str, req: Request):
    _require_bearer(req)
    return _xml({"userId": user_id, "lat": 0.0, "lon": 0.0}, "Location")


def create_app():
    return app


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)


