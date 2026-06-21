# RNA 3D Folding Inference Pipeline

<p align="center">
  <img width="100%" alt="RNA 3D Folding pipeline" src="https://github.com/user-attachments/assets/2b38e52d-06bf-497f-884a-10d6111f76bb" />
</p>

A compact inference pipeline for the **Stanford RNA 3D Folding Part 2** Kaggle competition. Given RNA sequences, the pipeline predicts residue-level 3D coordinates and writes a valid `submission.csv`.

**Reported leaderboard result:** TM-score **0.448**.

> This repository contains code only. Kaggle credentials, datasets, model checkpoints, logs, and generated submissions are excluded.

---

## Background

The task is to predict RNA tertiary structure from sequence-level input. For each RNA target, the submission provides multiple candidate structures. Each row in `submission.csv` corresponds to one residue, and each candidate structure is represented by coordinate triples:

```text
x_1, y_1, z_1, ..., x_10, y_10, z_10
```

The competition uses **TM-score** as the evaluation metric:

$$
\mathrm{TM\text{-}score}=\max\left(\frac{1}{L_{\mathrm{ref}}}\sum_{i=1}^{L_{\mathrm{align}}}\frac{1}{1+\left(\frac{d_i}{d_0}\right)^2}\right)
$$

where $L_{\mathrm{ref}}$ is the number of residues in the experimental reference structure, $L_{\mathrm{align}}$ is the number of aligned residues, and $d_i$ is the distance between the $i$-th aligned residue pair. For $L_{\mathrm{ref}}\ge 30$:

$$
d_0 = 0.6(L_{\mathrm{ref}}-0.5)^{1/2}-2.5
$$

Higher TM-score is better.

---

## Architecture

```text
RNA sequence
    |
    v
Template-Based Modeling
    |-- enough templates -> coordinate transfer
    |
    |-- missing candidates
    v
Protenix inference
    |-- short RNA -> single-pass generation
    |-- long RNA  -> chunked generation + overlap alignment
    |
    v
Merge candidates + post-process coordinates
    |
    v
outputs/submission.csv
```

Core components:

- **TBM:** finds similar training RNA structures and transfers coordinates.
- **Protenix:** fills missing candidates using `protenix_base_20250630_v1.0.0.pt` for inference only.
- **Chunking:** splits long RNA targets into overlapping windows and merges predictions after inference.
- **Submission writer:** combines TBM and Protenix candidates into the Kaggle format.

No local fine-tuning is performed.

---

## Project Structure

```text
.
├── main.py
├── requirements.txt
├── README.md
├── .gitignore
├── scripts/
│   ├── setup_env.sh
│   ├── download_assets.sh
│   └── run_inference.sh
└── tools/
    ├── check_paths.py
    └── inspect_data.py
```

Expected runtime layout after downloading assets:

```text
/root/autodl-tmp/RNA3D_Project/
├── main.py
├── data/stanford-rna-3d-folding-2/
├── Protenix-v1/
│   ├── checkpoint/protenix_base_20250630_v1.0.0.pt
│   ├── common/components.cif
│   └── common/components.cif.rdkit_mol.pkl
├── outputs/
└── logs/
```

---

## Installation and Usage

### 1. Prepare the project directory

```bash
cd /root/autodl-tmp
mkdir -p RNA3D_Project
cd RNA3D_Project
```

Copy this repository into the directory.

### 2. Create the environment

```bash
bash scripts/setup_env.sh
conda activate rna3d
```

### 3. Download data and model assets

```bash
bash scripts/download_assets.sh
```

When prompted, paste your own Kaggle API token:

```text
KGAT_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

The script downloads:

```text
stanford-rna-3d-folding-2
qiweiyin/protenix-v1-adjusted
```

If the competition data download fails, accept the Kaggle competition rules in the browser first.

### 4. Verify paths

```bash
python tools/check_paths.py
```

All required files should be marked `OK`.

### 5. Run inference

```bash
bash scripts/run_inference.sh
```

Monitor logs:

```bash
tail -f /root/autodl-tmp/RNA3D_Project/logs/rna3d_full_*.log
```

Final output:

```text
/root/autodl-tmp/RNA3D_Project/outputs/submission.csv
```

### 6. Inspect data and results

```bash
python tools/inspect_data.py
head outputs/submission.csv
```

---

## Git Tracking Policy

The following files and directories are intentionally excluded:

```text
data/
Protenix-v1/
outputs/
logs/
downloads/
protenix_dataset/
*.zip
*.pt
~/.kaggle/
```

Do not commit Kaggle tokens, competition data, Protenix checkpoints, generated logs, or submission files.
