import os
from dotenv import load_dotenv, find_dotenv
import psycopg2
from psycopg2.extras import RealDictCursor

# Load .env from repo root (or nearest) once on import
load_dotenv(find_dotenv(), override=False)

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

def _require(name: str, value: str):
    if value is None or str(value).strip() == "":
        raise RuntimeError(f"Environment variable {name} is required (set it in .env)")
    return value

def get_conn():
    # Validate required variables just before connecting
    host = _require("DB_HOST", DB_HOST)
    port = _require("DB_PORT", DB_PORT)
    name = _require("DB_NAME", DB_NAME)
    user = _require("DB_USER", DB_USER)
    password = _require("DB_PASSWORD", DB_PASSWORD)
    conn = psycopg2.connect(
        host=host,
        port=port,
        dbname=name,
        user=user,
        password=password,
        cursor_factory=RealDictCursor
    )
    conn.autocommit = True
    return conn

