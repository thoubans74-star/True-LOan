import os
import shutil

backup_dir = r"..\lib_stale_backup"
active_dir = r"lib"

copied_count = 0
for root, dirs, files in os.walk(backup_dir):
    for file in files:
        backup_file_path = os.path.join(root, file)
        rel_path = os.path.relpath(backup_file_path, backup_dir)
        active_file_path = os.path.join(active_dir, rel_path)
        
        # If the file does not exist in the active directory, copy it!
        if not os.path.exists(active_file_path):
            os.makedirs(os.path.dirname(active_file_path), exist_ok=True)
            shutil.copy2(backup_file_path, active_file_path)
            copied_count += 1
            print(f"Copied missing file from backup: {rel_path}")

print(f"Total missing files restored: {copied_count}")
