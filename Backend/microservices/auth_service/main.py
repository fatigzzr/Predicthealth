# auth_service/main.py
from fastapi import FastAPI, Request
from utils.xml_utils import parse_xml, to_xml
from auth import create_jwt
from users_db import authenticate
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/login")
async def login(request: Request):
    data = parse_xml(await request.body())
    email = data["login"]["email"]
    contraseña = data["login"]["contraseña"]

    if not authenticate(email, contraseña):
        return to_xml({"status": "error", "message": "Invalid credentials"})

    token = create_jwt(email)
    return to_xml({"status": "success", "token": token})
