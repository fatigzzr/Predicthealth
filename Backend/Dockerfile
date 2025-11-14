FROM python:3.11-slim AS base

# Avoid Python writing .pyc files and ensure stdout/err are flushed
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# psycopg2 needs libpq binaries and build headers
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY Backend/. .

EXPOSE 5001

# App reads all configuration (DB, JWT, etc.) from env vars.
CMD ["python", "app.py"]
