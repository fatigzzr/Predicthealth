$ErrorActionPreference = "Stop"

Write-Host "Starting Redis is required separately (docker or local service)."

Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/gateway; uvicorn main:app --reload --port 5001" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/auth_service; uvicorn main:app --reload --port 8001" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/user_ingest_service; uvicorn main:app --reload --port 8002" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/health_service; uvicorn main:app --reload --port 8003" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/geolocation_service; uvicorn main:app --reload --port 8004" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/recommendations_service; uvicorn main:app --reload --port 8005" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/document_service; uvicorn main:app --reload --port 8006" | Out-Null
Start-Process powershell -ArgumentList "-NoExit","-Command","cd services/prediction_service; uvicorn main:app --reload --port 8007" | Out-Null

Write-Host "All services launched."


