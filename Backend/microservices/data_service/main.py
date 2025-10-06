# data_service/main.py
from fastapi import FastAPI, Request, Header
from utils.xml_utils import parse_xml, to_xml
from auth_service.auth import verify_jwt

app = FastAPI()

@app.post("/submit_form")
async def submit_form(request: Request, authorization: str = Header(None)):
    user_id = verify_jwt(authorization.split(" ")[1])
    data = parse_xml(await request.body())
    # store form data
    return to_xml({"status": "success", "user_id": user_id})
