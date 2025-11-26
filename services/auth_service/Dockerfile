FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps for psycopg2 and build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Python deps
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# App source (services + shared + ML assets under Backend)
COPY Backend ./Backend
COPY services ./services

# Defaults can be overridden at runtime
ENV PORT=8001 \
    WORKERS=4

EXPOSE 8001

CMD ["sh", "-c", "gunicorn services.auth_service.main:app --workers ${WORKERS:-4} --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT:-8001}"]
