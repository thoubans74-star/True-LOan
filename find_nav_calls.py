import os

path = r"lib/login/login_screen.dart"
if os.path.exists(path):
    for idx, line in enumerate(open(path, "r", encoding="utf-8")):
        if "Navigator" in line or "MainNavigation" in line or "NewHomeScreen" in line:
            print(f"Line {idx+1}: {line.strip()}")
else:
    print("Not found")
