import os
from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dicttoxml import dicttoxml
import xmltodict
from services.shared.auth import verify_jwt_and_jti

APP_PORT = int(os.getenv("DOCS_PORT", "8006"))

app = FastAPI(title="Document Service", version="0.1.0")
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


@app.post("/documents")
async def create_document(req: Request):
    _require_bearer(req)
    body = (await req.body()).decode()
    _ = xmltodict.parse(body) if body else {}
    return _xml({"documentId": "doc-1"}, "DocumentReceipt")


@app.get("/documents/{doc_id}/extractions")
async def get_extractions(doc_id: str, req: Request):
    _require_bearer(req)
    return _xml({"documentId": doc_id, "fields": []}, "Extractions")


@app.post("/documents/{doc_id}/confirm")
async def confirm_extractions(doc_id: str, req: Request):
    _require_bearer(req)
    body = (await req.body()).decode()
    _ = xmltodict.parse(body) if body else {}
    return _xml({"documentId": doc_id, "status": "confirmed"}, "ConfirmResponse")


def create_app():
    return app


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)


