# Production Deployment - Windows (PowerShell)

## Start All Services with Uvicorn

**Note:** Gunicorn does not support Windows. Use Uvicorn with `--workers` flag for multi-process mode.

```powershell
# Auth Service (4 workers)
uvicorn services.auth_service.main:app --host 0.0.0.0 --port 8001 --workers 4

# Register Service (2 workers)
uvicorn services.register_service.main:app --host 0.0.0.0 --port 8002 --workers 2

# Patient Service (2 workers)
uvicorn services.patient_service.main:app --host 0.0.0.0 --port 8003 --workers 2

# Health Service (2 workers)
uvicorn services.health_service.main:app --host 0.0.0.0 --port 8004 --workers 2

# Diabetes Service (4 workers)
uvicorn services.diabetes_service.main:app --host 0.0.0.0 --port 8008 --workers 4

# Hypertension Service (4 workers)
uvicorn services.hypertension_service.main:app --host 0.0.0.0 --port 8009 --workers 4

# Data Service (4 workers)
uvicorn services.data_service.main:app --host 0.0.0.0 --port 8010 --workers 4

# Recommendations Service (2 workers)
uvicorn services.recommendations_service.main:app --host 0.0.0.0 --port 8011 --workers 2
```

## Run All in Background (PowerShell)

```powershell
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.auth_service.main:app --host 0.0.0.0 --port 8001 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.register_service.main:app --host 0.0.0.0 --port 8002 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.patient_service.main:app --host 0.0.0.0 --port 8003 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.health_service.main:app --host 0.0.0.0 --port 8004 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.diabetes_service.main:app --host 0.0.0.0 --port 8008 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.hypertension_service.main:app --host 0.0.0.0 --port 8009 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.data_service.main:app --host 0.0.0.0 --port 8010 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.recommendations_service.main:app --host 0.0.0.0 --port 8011 --workers 2"
```

## Notes

- Uvicorn's `--workers` on Windows uses the `multiprocess` spawning method
- For true production (Linux), use Gunicorn (see `PRODUCTION.md`)
- Worker count: CPU-bound services (ML models) use 4 workers, I/O-bound use 2 workers
