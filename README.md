# Stanford RNA 3D Folding Inference Pipeline

This repository contains a cleaned Python inference pipeline converted from a Kaggle notebook for **Stanford RNA 3D Folding Part 2**. It does not include Kaggle credentials, competition data, Protenix source files, checkpoints, or generated submissions.

## Layout

```text
RNA3D_Project/
├── main.py
├── requirements.txt
├── README.md
├── scripts/
│   ├── setup_env.sh
│   ├── download_assets.sh
│   └── run_inference.sh
└── tools/
    ├── check_paths.py
    └── inspect_data.py
```

The default runtime path is:

```text
/root/autodl-tmp/RNA3D_Project
```

Expected downloaded assets:

```text
RNA3D_Project/
├── data/stanford-rna-3d-folding-2/
├── Protenix-v1/
│   ├── checkpoint/protenix_base_20250630_v1.0.0.pt
│   └── common/
└── outputs/submission.csv
```

## 1. Create the environment

```bash
cd /root/autodl-tmp/RNA3D_Project
bash scripts/setup_env.sh
```

## 2. Download data and Protenix assets

Create your own Kaggle API token, then run:

```bash
cd /root/autodl-tmp/RNA3D_Project
bash scripts/download_assets.sh
```

When prompted, paste only your own `KGAT_...` token. The script downloads:

- Competition data: `stanford-rna-3d-folding-2`
- Protenix source/checkpoint dataset: `qiweiyin/protenix-v1-adjusted`

If the competition download fails, open the Kaggle competition page and accept the rules first.

## 3. Check paths

```bash
python tools/check_paths.py
```

All required files should be marked `OK`.

## 4. Run inference

```bash
bash scripts/run_inference.sh
```

Monitor logs and GPU usage:

```bash
tail -f /root/autodl-tmp/RNA3D_Project/logs/rna3d_full_*.log
watch -n 2 nvidia-smi
```

Final output:

```text
/root/autodl-tmp/RNA3D_Project/outputs/submission.csv
```

## Inspect downloaded data

```bash
python tools/inspect_data.py
```

## Notes

- Do not commit Kaggle tokens, `data/`, `Protenix-v1/`, checkpoints, logs, or outputs.
- `protenix_base_20250630_v1.0.0.pt` is loaded for inference only. This repository does not fine-tune Protenix.
- `main.py` keeps the original inference logic while removing notebook-specific cells and reducing redundant comments.
