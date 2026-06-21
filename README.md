# RNA 3D Folding Inference Pipeline

A lightweight, reproducible inference pipeline for the **Stanford RNA 3D Folding Part 2** Kaggle competition. The task is to predict RNA tertiary structures from nucleotide sequences by submitting 3D coordinates for each residue. This repository converts the original Kaggle notebook into a cleaner Python project for server-side inference.

**Reported leaderboard result:** TM-score **0.448**.

> This repository contains code only. Kaggle credentials, competition data, Protenix source files, checkpoints, generated logs, and submission files are intentionally excluded.

---

## Competition Background

RNA molecules are not only information carriers; many RNAs fold into complex 3D structures that determine their biological function. The Stanford RNA 3D Folding Part 2 competition asks participants to infer RNA 3D coordinates from sequence-level input. Submissions are evaluated with **TM-score**, a structure similarity metric ranging from 0 to 1, where higher is better. The final competition score is based on best-of-multiple predicted structures for each target RNA.

At submission time, each RNA target is represented residue by residue. For each residue, the submission contains coordinates of the predicted C1' atom across multiple candidate structures.

---

## Method Overview

This solution uses a hybrid inference strategy:

```text
RNA sequence
    |
    v
Template-Based Modeling (TBM)
    |-- high-similarity templates found  -> coordinate transfer + gap handling
    |
    |-- insufficient templates           -> Protenix structure generation
                                                |
                                                |-- short RNA: single-pass inference
                                                |-- long RNA : chunked inference + overlap alignment
    |
    v
Candidate structure merge + post-processing
    |
    v
submission.csv
```

### 1. Template-Based Modeling

The pipeline first builds a template pool from the provided training structures. For each test RNA, it performs sequence alignment against available templates and transfers coordinates from sufficiently similar training structures. This part is mainly CPU-bound.

### 2. Protenix-Based Generation

If TBM does not provide enough candidate structures, the missing predictions are generated using Protenix:

```text
Protenix-v1/checkpoint/protenix_base_20250630_v1.0.0.pt
```

The checkpoint is loaded for inference only. This repository does **not** fine-tune Protenix.

### 3. Long-Sequence Chunking

Long RNA sequences are split into overlapping windows before Protenix inference. The predicted chunks are later aligned and merged through their overlap regions.

### 4. Submission Generation

The final output is written to:

```text
outputs/submission.csv
```

The original notebook behavior is preserved in `main.py`. Before submitting, always compare the generated columns with the official `sample_submission.csv` from the current competition data release.

---

## Repository Structure

```text
.
├── main.py                     # Main inference entry point
├── requirements.txt            # Python dependencies
├── README.md
├── .gitignore
├── scripts/
│   ├── setup_env.sh            # Create environment and install dependencies
│   ├── download_assets.sh      # Configure Kaggle token and download assets
│   └── run_inference.sh        # Launch full inference with nohup
└── tools/
    ├── check_paths.py          # Verify required files and directories
    └── inspect_data.py         # Inspect downloaded data and outputs
```

Expected runtime layout after downloading data:

```text
/root/autodl-tmp/RNA3D_Project/
├── main.py
├── data/
│   └── stanford-rna-3d-folding-2/
│       ├── train_sequences.csv
│       ├── train_labels.csv
│       ├── validation_sequences.csv
│       ├── validation_labels.csv
│       ├── test_sequences.csv
│       ├── sample_submission.csv
│       ├── MSA/
│       ├── PDB_RNA/
│       └── extra/
├── Protenix-v1/
│   ├── checkpoint/
│   │   └── protenix_base_20250630_v1.0.0.pt
│   ├── common/
│   │   ├── components.cif
│   │   └── components.cif.rdkit_mol.pkl
│   ├── protenix/
│   ├── runner/
│   └── configs/
├── outputs/
└── logs/
```

---

## Quick Start

### 1. Clone or upload this repository

```bash
cd /root/autodl-tmp
mkdir -p RNA3D_Project
cd RNA3D_Project
```

Copy the repository files into this directory.

### 2. Create the environment

```bash
bash scripts/setup_env.sh
```

Then activate it:

```bash
conda activate rna3d
```

### 3. Download Kaggle data and Protenix assets

```bash
bash scripts/download_assets.sh
```

When prompted, paste your own Kaggle API token in the form:

```text
KGAT_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

The token is read interactively. Do not hard-code it into the repository.

The script downloads:

```text
Kaggle competition data:
  stanford-rna-3d-folding-2

Kaggle dataset containing Protenix files:
  qiweiyin/protenix-v1-adjusted
```

If the competition data download fails, open the Kaggle competition page in a browser and accept the competition rules first.

### 4. Verify paths

```bash
python tools/check_paths.py
```

Expected key files:

```text
Protenix-v1/checkpoint/protenix_base_20250630_v1.0.0.pt
Protenix-v1/common/components.cif
Protenix-v1/common/components.cif.rdkit_mol.pkl
data/stanford-rna-3d-folding-2/train_sequences.csv
data/stanford-rna-3d-folding-2/train_labels.csv
data/stanford-rna-3d-folding-2/test_sequences.csv
```

All required files should be marked `OK`.

### 5. Run full inference

```bash
bash scripts/run_inference.sh
```

Monitor logs:

```bash
tail -f /root/autodl-tmp/RNA3D_Project/logs/rna3d_full_*.log
```

Monitor GPU usage:

```bash
watch -n 2 nvidia-smi
```

Final output:

```text
/root/autodl-tmp/RNA3D_Project/outputs/submission.csv
```

---

## Inspect Data and Results

Preview dataset files, directory sizes, and generated submission:

```bash
python tools/inspect_data.py
```

Check the generated submission manually:

```bash
wc -l outputs/submission.csv
head outputs/submission.csv
```

Each row corresponds to one RNA residue. Coordinate columns are grouped by candidate structure, for example:

```text
x_1, y_1, z_1
x_2, y_2, z_2
...
```

For one RNA target with length `L`, one candidate structure corresponds to an `L × 3` coordinate matrix.

---

## Runtime Notes

- TBM and sequence alignment are mostly CPU-bound.
- Protenix inference is GPU-bound and can take significantly longer on long RNA targets.
- Long sequences are processed as multiple overlapping chunks.
- The generated file can be large but should be much smaller than the downloaded competition data.

Recommended hardware:

```text
GPU: 24 GB VRAM or higher recommended
RAM: 32 GB or higher recommended
Disk: large enough for competition data, Protenix assets, logs, and outputs
```

---

## What Is Not Included

The following are excluded from Git tracking:

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

This avoids committing private credentials, large datasets, model checkpoints, and generated submissions.

---

## Important Notes

- This repository is an inference pipeline, not a training pipeline.
- `protenix_base_20250630_v1.0.0.pt` is loaded directly for inference.
- No local fine-tuning is performed.
- The Protenix source and checkpoint are downloaded from the Kaggle dataset specified in `scripts/download_assets.sh`.
- The final score may vary with competition data version, runtime configuration, and candidate generation settings.

---

## Citation and Acknowledgements

This project is based on the Stanford RNA 3D Folding Part 2 Kaggle competition and uses Protenix assets for structure generation. Please follow the licenses and terms of use of Kaggle, the competition dataset, and Protenix when reusing this code.

