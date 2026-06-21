#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-/root/autodl-tmp/RNA3D_Project}"
CONDA_ENV="${CONDA_ENV:-rna3d}"
COMPETITION="stanford-rna-3d-folding-2"
PROTENIX_DATASET="qiweiyin/protenix-v1-adjusted"

if [ -f /root/miniconda3/etc/profile.d/conda.sh ]; then
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate "${CONDA_ENV}" || true
fi

python -m pip install -U kaggle >/dev/null

mkdir -p ~/.kaggle "${PROJECT_DIR}/downloads" "${PROJECT_DIR}/data/${COMPETITION}" "${PROJECT_DIR}/outputs"

if [ -z "${KAGGLE_API_TOKEN:-}" ]; then
  read -s -p "Paste your Kaggle API Token, only KGAT_xxx: " KAGGLE_API_TOKEN
  echo
fi

printf "%s" "${KAGGLE_API_TOKEN}" | tr -d '[:space:]' > ~/.kaggle/access_token
chmod 600 ~/.kaggle/access_token

python - <<'PY'
from pathlib import Path
s = (Path.home() / '.kaggle' / 'access_token').read_text().strip()
if not s.startswith('KGAT_'):
    raise SystemExit('ERROR: token must start with KGAT_.')
if any(ord(c) > 127 for c in s):
    raise SystemExit('ERROR: token contains non-ASCII characters. Paste only the KGAT token.')
print('Kaggle token format OK')
PY

kaggle competitions list >/dev/null

echo "Downloading Protenix dataset: ${PROTENIX_DATASET}"
kaggle datasets download -d "${PROTENIX_DATASET}" -p "${PROJECT_DIR}/downloads" --force
rm -rf "${PROJECT_DIR}/protenix_dataset" "${PROJECT_DIR}/Protenix-v1"
mkdir -p "${PROJECT_DIR}/protenix_dataset"
unzip -q -o "${PROJECT_DIR}/downloads/protenix-v1-adjusted.zip" -d "${PROJECT_DIR}/protenix_dataset"

PROTENIX_SRC=$(find "${PROJECT_DIR}/protenix_dataset" -type d -name "Protenix-v1" | head -n 1)
if [ -z "${PROTENIX_SRC}" ]; then
  echo "ERROR: Protenix-v1 directory not found after unzip."
  exit 1
fi
cp -r "${PROTENIX_SRC}" "${PROJECT_DIR}/Protenix-v1"

echo "Downloading Kaggle competition data: ${COMPETITION}"
set +e
kaggle competitions download -c "${COMPETITION}" -p "${PROJECT_DIR}/data/${COMPETITION}" --force
STATUS=$?
set -e
if [ "${STATUS}" -ne 0 ]; then
  echo "ERROR: competition download failed. Open the competition page and accept the rules, then rerun this script."
  exit "${STATUS}"
fi

unzip -q -o "${PROJECT_DIR}/data/${COMPETITION}/${COMPETITION}.zip" -d "${PROJECT_DIR}/data/${COMPETITION}"

cd "${PROJECT_DIR}"
python tools/check_paths.py

echo "Assets are ready under ${PROJECT_DIR}."
