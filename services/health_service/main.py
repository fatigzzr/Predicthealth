import os
from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dicttoxml import dicttoxml
import xmltodict

from services.shared.auth import verify_jwt_and_jti

APP_PORT = int(os.getenv("HEALTH_PORT", "8003"))

app = FastAPI(title="Health Service", version="0.1.0")
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


@app.get("/health/health")
async def health():
    return _xml({"status": "ok"}, "Health")


@app.get("/health/entities")
async def entities(req: Request):
    _require_bearer(req)
    # Placeholder: list of entities
    return _xml({"total": 0, "entities": []}, "Entities")


@app.get("/health/entities/{name}")
async def entity_data(name: str, req: Request):
    _require_bearer(req)
    # Placeholder: empty dataset
    return _xml({"entidad": name, "columnas": [], "datos": []}, "EntityData")


@app.post("/health/entities/{name}")
async def entity_insert(name: str, req: Request):
    _require_bearer(req)
    # Accept XML from gateway; parse payload
    body = (await req.body()).decode()
    _ = xmltodict.parse(body) if body else {}
    return _xml({"success": True, "inserted_id": 0}, "InsertResponse")


@app.put("/health/entities/{name}/{pk}")
async def entity_update(name: str, pk: str, req: Request):
    _require_bearer(req)
    body = (await req.body()).decode()
    _ = xmltodict.parse(body) if body else {}
    return _xml({"success": True, "updated": 1}, "UpdateResponse")


@app.delete("/health/entities/{name}/{pk}")
async def entity_delete(name: str, pk: str, req: Request):
    _require_bearer(req)
    return _xml({"success": True, "deleted": 1}, "DeleteResponse")


def create_app():
    return app


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)


