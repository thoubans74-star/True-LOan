import os

dt_dir = r"c:\Users\ELCOT\StudioProjects\tm\.dart_tool"
if os.path.exists(dt_dir):
    for root, dirs, files in os.walk(dt_dir):
        for file in files:
            if file.endswith(".dart") or "backup" in file.lower() or "lib" in file.lower():
                path = os.path.join(root, file)
                print(f"File: {path} ({os.path.getsize(path)} bytes)")
print("Done.")
