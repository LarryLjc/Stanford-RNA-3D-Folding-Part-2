from pathlib import Path
import subprocess
import pandas as pd

ROOT = Path('/root/autodl-tmp/RNA3D_Project')
DATA = ROOT / 'data' / 'stanford-rna-3d-folding-2'
OUTPUT = ROOT / 'outputs' / 'submission.csv'

def sh(cmd):
    return subprocess.check_output(cmd, shell=True, text=True).strip()

def size(path):
    return sh(f'du -sh {path}').split()[0] if Path(path).exists() else 'NA'

def preview_csv(path, n=5):
    print('\n' + '=' * 100)
    print(path, 'size=', size(path))
    if Path(path).exists():
        df = pd.read_csv(path, nrows=n)
        print('shape preview:', df.shape)
        print('columns:', list(df.columns))
        print(df)

print('Directory sizes')
for p in [ROOT, DATA, ROOT / 'Protenix-v1', ROOT / 'outputs', ROOT / 'downloads', ROOT / 'protenix_dataset']:
    if p.exists():
        print(f'{p} -> {size(p)}')

for f in [
    DATA / 'train_sequences.csv',
    DATA / 'train_labels.csv',
    DATA / 'validation_sequences.csv',
    DATA / 'validation_labels.csv',
    DATA / 'test_sequences.csv',
    DATA / 'sample_submission.csv',
    OUTPUT,
]:
    preview_csv(f)

print('\nLargest directories/files')
print(sh(f'du -h --max-depth=2 {ROOT} | sort -hr | head -50'))
