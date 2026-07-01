import os

backup_dir = r"..\lib_stale_backup"
found = False
for root, dirs, files in os.walk(backup_dir):
    for file in files:
        if file.endswith(".dart"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
                if "BookmarksScreen" in content or "BookmarkManager" in content:
                    print(f"Found in backup: {os.path.relpath(path, backup_dir)}")
                    found = True

if not found:
    print("Not found in backup.")
