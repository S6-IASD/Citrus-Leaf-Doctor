import os
import shutil
import random

# ══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

SRC_DIR    = r'D:\CV\Dataset CV Resized'          # 📁 Dossier source
DST_DIR    = r'D:\CV\splitdataset'    # 📁 Dossier de destination avec train/val/test
FOLDERS    = ['Anthracnose', 'Ash weevil', 'Canker', 'Greening', 'Healthy', 'Leaf miner']  # Sous-dossiers source

SPLIT_COUNTS = {
    'train' : 7000,
    'val'   : 1500,
    'test'  : 1500,
}

SEED = 42  # Pour reproductibilité

# ══════════════════════════════════════════════════════════════════════════════
# SCRIPT
# ══════════════════════════════════════════════════════════════════════════════

random.seed(SEED)

print('=' * 60)
print('📂  SPLIT DATASET')
print('=' * 60)
print(f'  Source      : {SRC_DIR}')
print(f'  Destination : {DST_DIR}')
print(f'  Train       : {SPLIT_COUNTS["train"]} images/dossier')
print(f'  Val         : {SPLIT_COUNTS["val"]} images/dossier')
print(f'  Test        : {SPLIT_COUNTS["test"]} images/dossier')
print(f'  Total/dossier: {sum(SPLIT_COUNTS.values())} images')
print('=' * 60)

total_needed = sum(SPLIT_COUNTS.values())  # 10 000 per folder

for folder in FOLDERS:
    src_folder = os.path.join(SRC_DIR, folder)

    # Récupérer toutes les images
    all_images = [
        f for f in os.listdir(src_folder)
        if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp', '.webp'))
    ]

    if len(all_images) < total_needed:
        print(f'  ⚠️  {folder} : seulement {len(all_images)} images disponibles (besoin de {total_needed})')
        total_needed_adj = len(all_images)
    else:
        total_needed_adj = total_needed

    # Mélange aléatoire
    random.shuffle(all_images)

    # Découpage
    train_imgs = all_images[:SPLIT_COUNTS['train']]
    val_imgs   = all_images[SPLIT_COUNTS['train'] : SPLIT_COUNTS['train'] + SPLIT_COUNTS['val']]
    test_imgs  = all_images[SPLIT_COUNTS['train'] + SPLIT_COUNTS['val'] : total_needed_adj]

    splits = {
        'train' : train_imgs,
        'val'   : val_imgs,
        'test'  : test_imgs,
    }

    print(f'\n  📁 Dossier {folder}')

    for split, imgs in splits.items():
        dst_folder = os.path.join(DST_DIR, split, folder)
        os.makedirs(dst_folder, exist_ok=True)

        for img in imgs:
            src_path = os.path.join(src_folder, img)
            dst_path = os.path.join(dst_folder, img)
            shutil.copy2(src_path, dst_path)

        print(f'     {split:5s} → {len(imgs):,} images copiées dans {dst_folder}')

print('\n' + '=' * 60)
print('✅  RÉSUMÉ FINAL')
print('=' * 60)

for split in ['train', 'val', 'test']:
    split_path = os.path.join(DST_DIR, split)
    total = 0
    for folder in FOLDERS:
        n = len(os.listdir(os.path.join(split_path, folder)))
        total += n
    print(f'  {split:5s} → {total:,} images au total ({total // len(FOLDERS):,} / dossier)')

print('=' * 60)
print(f'  📦 Dataset splitté disponible dans : {DST_DIR}/')
print('=' * 60)