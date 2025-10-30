# Install dependencies
pip install fastapi uvicorn asyncpg xmltodict

# Run the service
uvicorn register_service.main:app --reload --host 0.0.0.0 --port 8000