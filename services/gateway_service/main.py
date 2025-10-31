from fastapi import FastAPI, Request, Response
from fastapi.openapi.docs import get_swagger_ui_html
import requests
import httpx

app = FastAPI(title="API Gateway", docs_url=None, redoc_url=None)

MICROSERVICES = {
    "auth": "http://127.0.0.1:8001/openapi.json",
    "register": "http://127.0.0.1:8002/openapi.json",
    "user_data": "http://127.0.0.1:8003/openapi.json",
    "health_data": "http://127.0.0.1:8004/openapi.json",
    "geo_data": "http://127.0.0.1:8005/openapi.json",
    "recommend": "http://127.0.0.1:8006/openapi.json",
    "documents": "http://127.0.0.1:8007/openapi.json",
    "prediction": "http://127.0.0.1:8008/openapi.json",
}


def merge_openapi_specs():
    merged = {
        "openapi": "3.1.0",
        "info": {"title": "All Microservices API", "version": "1.0.0"},
        "paths": {},
        "components": {"schemas": {}},
    }

    for name, url in MICROSERVICES.items():
        try:
            resp = requests.get(url, timeout=3)
            resp.raise_for_status()
            spec = resp.json()

            # Prefix paths with service name to avoid collisions
            for path, val in spec.get("paths", {}).items():
                merged_path = f"/{name}{path}" if not path.startswith(f"/{name}") else path
                merged["paths"][merged_path] = val

            # Merge schemas safely
            schemas = spec.get("components", {}).get("schemas", {})
            for s_name, s_val in schemas.items():
                key = f"{name}_{s_name}" if s_name in merged["components"]["schemas"] else s_name
                merged["components"]["schemas"][key] = s_val

            print(f"[INFO] Fetched OpenAPI spec from {name} ({url})")
        except Exception as e:
            print(f"[WARNING] Could not fetch {name} spec: {e}")

    return merged


@app.get("/openapi.json")
def openapi_json():
    return merge_openapi_specs()


@app.get("/docs")
def swagger_ui():
    return get_swagger_ui_html(openapi_url="/openapi.json", title="All Microservices API Docs")


@app.api_route("/{service}/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy(service: str, path: str, request: Request):
    if service not in MICROSERVICES:
        return {"error": "unknown service"}

    url = f"{MICROSERVICES[service].replace('/openapi.json','')}/{path}"
    async with httpx.AsyncClient() as client:
        resp = await client.request(
            method=request.method,
            url=url,
            headers=request.headers.raw,
            content=await request.body()
        )
    return resp.text


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
