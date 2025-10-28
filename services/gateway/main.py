import os
import json
from typing import Optional

from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
import httpx

# Simple JSON <-> XML gateway.
# - Receives JSON from React
# - Converts to XML when forwarding to backend services
# - Converts XML responses from services back to JSON for clients

GATEWAY_PORT = int(os.getenv("GATEWAY_PORT", "5001"))

# Service base URLs (different ports, no nginx)
SERVICE_URLS = {
    "auth": os.getenv("AUTH_URL", "http://localhost:8001"),
    "health": os.getenv("HEALTH_URL", "http://localhost:8003"),
    "users": os.getenv("USERS_URL", "http://localhost:8002"),
    "geo": os.getenv("GEO_URL", "http://localhost:8004"),
    "recs": os.getenv("RECS_URL", "http://localhost:8005"),
    "docs": os.getenv("DOCS_URL", "http://localhost:8006"),
    "preds": os.getenv("PREDS_URL", "http://localhost:8007"),
}

from dicttoxml import dicttoxml
import xmltodict


def json_to_xml(data: dict, root_name: str = "Request") -> bytes:
    return dicttoxml(data, custom_root=root_name, attr_type=False)


def xml_to_json(xml_text: str) -> dict:
    return xmltodict.parse(xml_text)


app = FastAPI(title="PredictHealth Gateway", version="0.1.0")

allowed_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


def _bearer(req: Request) -> Optional[str]:
    auth = req.headers.get("authorization") or req.headers.get("Authorization")
    if not auth:
        return None
    parts = auth.split()
    if len(parts) == 2 and parts[0].lower() == "bearer":
        return parts[1]
    return None


async def forward_xml(
    method: str,
    service_key: str,
    path: str,
    req: Request,
    root_name: str = "Request",
):
    base = SERVICE_URLS[service_key]
    url = f"{base}{path}"
    token = _bearer(req)
    headers = {"Accept": "application/xml"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    body_bytes = None
    if method in ("POST", "PUT", "PATCH"):
        try:
            data = await req.json()
        except Exception:
            data = {}
        body_bytes = json_to_xml(data, root_name=root_name)
        headers["Content-Type"] = "application/xml"

    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.request(method, url, headers=headers, content=body_bytes, params=dict(req.query_params))

    # Convert XML response -> JSON
    content_type = resp.headers.get("content-type", "")
    text = resp.text
    status = resp.status_code
    if not text:
        return Response(status_code=status)
    try:
        data_dict = xml_to_json(text)
        return Response(content=json.dumps(data_dict), media_type="application/json", status_code=status)
    except Exception:
        # Fallback: return raw text if not XML
        return Response(content=text, media_type=content_type or "text/plain", status_code=status)


@app.get("/api/health")
async def gw_health():
    return {"status": "ok", "gateway": True}


# Auth endpoints
@app.post("/api/login")
async def gw_login(req: Request):
    return await forward_xml("POST", "auth", "/auth/login", req, root_name="LoginRequest")


@app.get("/api/me")
async def gw_me(req: Request):
    return await forward_xml("GET", "auth", "/auth/me", req)


# Health (entities + dashboards) sample routes
@app.get("/api/entidades")
async def gw_entities(req: Request):
    return await forward_xml("GET", "health", "/health/entities", req)


@app.get("/api/entidades/{entidad}")
async def gw_entity(entidad: str, req: Request):
    return await forward_xml("GET", "health", f"/health/entities/{entidad}", req)


@app.post("/api/entidades/{entidad}")
async def gw_entity_create(entidad: str, req: Request):
    return await forward_xml("POST", "health", f"/health/entities/{entidad}", req, root_name="InsertRequest")


@app.put("/api/entidades/{entidad}/{pk}")
async def gw_entity_update(entidad: str, pk: str, req: Request):
    return await forward_xml("PUT", "health", f"/health/entities/{entidad}/{pk}", req, root_name="UpdateRequest")


@app.delete("/api/entidades/{entidad}/{pk}")
async def gw_entity_delete(entidad: str, pk: str, req: Request):
    return await forward_xml("DELETE", "health", f"/health/entities/{entidad}/{pk}", req)


def create_app():
    return app


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=GATEWAY_PORT)


