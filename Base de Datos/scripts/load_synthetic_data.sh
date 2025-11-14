#!/bin/bash
set -euo pipefail

echo "[seed] Synthetic data loader started"

if [[ "${LOAD_SYNTHETIC_DATA:-false}" != "true" ]]; then
    echo "[seed] LOAD_SYNTHETIC_DATA is not 'true'; skipping synthetic dataset import"
    exit 0
fi

DATA_DIR="/seed-data"
declare -a DATASETS=(
    "diabetes_sql_commands.sql"
    "hypertension_sql_commands.sql"
)

missing_files=0
for dataset in "${DATASETS[@]}"; do
    if [[ ! -f "${DATA_DIR}/${dataset}" ]]; then
        echo "[seed] WARNING: ${dataset} not found in ${DATA_DIR}. Skipping this file."
        ((missing_files++)) || true
    fi
done

if [[ "${missing_files}" -eq "${#DATASETS[@]}" ]]; then
    echo "[seed] No dataset SQL files were found; aborting synthetic data load"
    exit 0
fi

for dataset in "${DATASETS[@]}"; do
    file_path="${DATA_DIR}/${dataset}"
    if [[ -f "${file_path}" ]]; then
        echo "[seed] Loading ${dataset} into ${POSTGRES_DB}"
        psql -v ON_ERROR_STOP=1 \
             -U "${POSTGRES_USER}" \
             -d "${POSTGRES_DB}" \
             -f "${file_path}"
    fi
done

echo "[seed] Synthetic data load completed"
