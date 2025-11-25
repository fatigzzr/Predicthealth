# Production Deployment Guide

## Overview
All microservices use FastAPI + Uvicorn. For production stress testing and high performance, use Gunicorn with Uvicorn workers.

## Quick Start (Development)
Use the commands in `README.md` — single Uvicorn process per service:
```powershell
py -m services.auth_service.main
py -m services.register_service.main
# etc.
```

## Production Mode (High Performance)

### Install Production Dependencies
```powershell
pip install -r requirements.txt
```

This installs:
- `uvicorn[standard]` - Uvicorn with performance extensions (httptools, uvloop, websockets)
- `gunicorn` - Process manager for multiple workers

### Start Services with Gunicorn (Recommended for Production)

#### Windows (PowerShell)
**Auth Service (4 workers):**
```powershell
gunicorn services.auth_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001
```

**Register Service (2 workers):**
```powershell
gunicorn services.register_service.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8002
```

**Patient Service (2 workers):**
```powershell
gunicorn services.patient_service.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8003
```

**Health Service (2 workers):**
```powershell
gunicorn services.health_service.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8004
```

**Diabetes Service (4 workers):**
```powershell
gunicorn services.diabetes_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8008
```

**Hypertension Service (4 workers):**
```powershell
gunicorn services.hypertension_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8009
```

**Data Service (4 workers):**
```powershell
gunicorn services.data_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8010
```

**Recommendations Service (2 workers):**
```powershell
gunicorn services.recommendations_service.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8011
```

### Worker Count Guidelines
- **CPU-bound services** (diabetes, hypertension with ML models): `workers = (2 × CPU cores) + 1`
- **I/O-bound services** (auth, register, patient, health): `workers = (2 × CPU cores)`
- **Light services** (recommendations): `workers = 2-4`

Example for 4-core CPU:
- Auth, Data, Diabetes, Hypertension: 4 workers
- Others: 2 workers

### Production Configuration Options

**Timeout (for long ML predictions):**
```powershell
gunicorn services.diabetes_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8008 --timeout 120
```

**Logging:**
```powershell
gunicorn services.auth_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001 --access-logfile access.log --error-logfile error.log --log-level info
```

**Graceful Restart:**
```powershell
gunicorn services.auth_service.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001 --graceful-timeout 30
```

## Performance Benchmarks (Expected)

With 4 workers on a 4-core CPU:
- **Auth login**: 500-1000 req/sec
- **Patient GET**: 1000-2000 req/sec
- **Diabetes prediction**: 50-200 req/sec (model-dependent)
- **Recommendations GET**: 500-1000 req/sec

## Troubleshooting

**Workers not starting:**
- Check ports aren't already in use: `netstat -ano | findstr :8001`
- Verify `.env` is loaded: `py -c "from dotenv import load_dotenv; load_dotenv(); import os; print(os.getenv('DB_HOST'))"`

**High CPU usage:**
- Reduce worker count
- Profile with `py-spy`: `pip install py-spy; py-spy top --pid <PID>`

**Memory leaks:**
- Monitor with `psutil`: `pip install psutil`
- Restart workers periodically: `--max-requests 1000 --max-requests-jitter 100`
