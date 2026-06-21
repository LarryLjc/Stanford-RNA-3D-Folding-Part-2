from pathlib import Path

ROOT = Path('/root/autodl-tmp/RNA3D_Project')
paths = [
    ROOT / 'Protenix-v1/checkpoint/protenix_base_20250630_v1.0.0.pt',
    ROOT / 'Protenix-v1/common/components.cif',
    ROOT / 'Protenix-v1/common/components.cif.rdkit_mol.pkl',
    ROOT / 'data/stanford-rna-3d-folding-2/train_sequences.csv',
    ROOT / 'data/stanford-rna-3d-folding-2/train_labels.csv',
    ROOT / 'data/stanford-rna-3d-folding-2/test_sequences.csv',
    ROOT / 'data/stanford-rna-3d-folding-2/sample_submission.csv',
]

ok = True
for p in paths:
    exists = p.exists()
    ok = ok and exists
    print(f'{p} -> {"OK" if exists else "MISSING"}')

print('\nAll required files are ready.' if ok else '\nMissing files. Run download_assets.sh first or check paths.')
raise SystemExit(0 if ok else 1)
