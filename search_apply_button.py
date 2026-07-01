path = r"lib/new_home/home_loan.dart"
with open(path, "r", encoding="utf-8") as f:
    for idx, line in enumerate(f):
        if idx >= 380:
            if "apply" in line.lower() or "button" in line.lower() or "gesture" in line.lower():
                print(f"Line {idx+1}: {line.strip()}")
