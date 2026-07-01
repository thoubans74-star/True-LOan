import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if step_type == "VIEW_FILE" and data.get("status") == "DONE":
            content = data.get("content", "")
            if "bookmark_manager.dart" in content:
                print(f"Step {step_index} | View of bookmark_manager.dart")
                for l in content.split("\n"):
                    if "Showing lines" in l:
                        print("  " + l.strip())
