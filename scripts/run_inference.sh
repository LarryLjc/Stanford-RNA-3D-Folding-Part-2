#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/root/autodl-tmp/RNA3D_Project}"
CONDA_ENV="${CONDA_ENV:-rna3d}"

source /root/miniconda3/etc/profile.d/conda.sh
conda activate "${CONDA_ENV}"

cd "${PROJECT_DIR}"
mkdir -p outputs workdir logs

export LAYERNORM_TYPE=torch
export RNA_MSA_DEPTH_LIMIT=512
export PYTHONPATH="${PROJECT_DIR}/Protenix-v1:${PYTHONPATH:-}"

python tools/check_paths.py

LOG_FILE="logs/rna3d_full_$(date +%Y%m%d_%H%M%S).log"
nohup python -u main.py > "${LOG_FILE}" 2>&1 &
echo $! > logs/rna3d_full.pid

echo "PID: $(cat logs/rna3d_full.pid)"
echo "Log: ${PROJECT_DIR}/${LOG_FILE}"
echo "tail -f ${PROJECT_DIR}/${LOG_FILE}"
