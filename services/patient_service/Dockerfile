FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY Backend ./Backend
COPY services ./services

ENV PORT=8003 \
    WORKERS=2

EXPOSE 8003

CMD ["sh", "-c", "gunicorn services.patient_service.main:app --workers ${WORKERS:-2} --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT:-8003}"]
