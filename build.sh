#!/bin/bash

set -euo pipefail

load_dotenv() {
  export $(grep -v '^#' .env | xargs)
}

echo "[BUILD] Loading environment variables from .env..."

load_dotenv

echo "[BUILD] Checking .env file and environment variables..."
if [ ! -f .env ]; then
    echo "[ERROR] .env file not found. Copy env.example to .env and fill it out."
    exit 1
fi

./scripts/check-env.sh

echo "[BUILD] Starting database initialization..."
docker-compose up --build -d init

echo "[BUILD] Initialization complete. Removing temporary containers..."
docker-compose rm -fs init ras

echo "[BUILD] Build completed successfully!"
