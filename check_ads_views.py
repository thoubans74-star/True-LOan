import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"

with open(path, "r", encoding="utf-8") as f:
    for line_str in f:
        data = json.loads(line_str)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if step_type == "VIEW_FILE" and data.get("status") == "DONE":
            content = data.get("content", "")
            
            # Find file path
            filepath = None
            for l in content.split("\n"):
                if "File Path: " in l:
                    filepath = l.split("`file:///")[1].replace("`", "").strip()
                    break
                    
            if filepath and (filepath.endswith("/ads_screen.dart") or filepath.endswith("\\ads_screen.dart")):
                print(f"Step {step_index} | View of actual ads_screen.dart")
                # Print lines shown
                lines_shown = []
                for l in content.split("\n"):
                    if "Showing lines" in l:
                        print("  " + l.strip())
                    parts = l.split(":", 1)
                    if len(parts) == 2 and parts[0].strip().isdigit():
                        lines_shown.append(int(parts[0].strip()))
                if lines_shown:
                    print(f"  Lines range: {min(lines_shown)} to {max(lines_shown)}")
                print(f"  Total lines in file at this step: {content.split('Total Lines: ')[1].split('\n')[0] if 'Total Lines: ' in content else 'unknown'}")
