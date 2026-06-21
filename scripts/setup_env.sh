#!/usr/bin/env bash
set -euo pipefail

source /root/miniconda3/etc/profile.d/conda.sh
conda create -n rna3d python=3.12 -y
conda activate rna3d

python -m pip install --upgrade pip setuptools wheel
pip install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu126
pip install numpy pandas tqdm scipy PyYAML ml-collections matplotlib ipywidgets py3Dmol pydantic optree protobuf icecream ipdb networkx einops
pip install biopython==1.86 biotite==1.6.0
pip install rdkit==2025.9.5 || pip install rdkit==2025.9.3
pip install modelcif==1.4 gemmi==0.6.7 pdbeccdutils==1.0.0 fair-esm==2.0.0 scikit-learn==1.7.1 scikit-learn-extra==0.3.0
pip install kaggle jupyterlab ipykernel
python -m ipykernel install --user --name rna3d --display-name "Python (rna3d)"

apt-get update
apt-get install -y unzip git wget hmmer kalign

echo "Environment rna3d is ready."
