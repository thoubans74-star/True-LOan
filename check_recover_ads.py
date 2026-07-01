import json
import os

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"

file_lines = {}

with open(path, "r", encoding="utf-8") as f:
    for line_str in f:
        data = json.loads(line_str)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        # Parse all steps in transcript
        if step_type == "VIEW_FILE" and data.get("status") == "DONE":
            content = data.get("content", "")
            
            filepath = None
            for l in content.split("\n"):
                if "File Path: " in l:
                    filepath = l.split("`file:///")[1].replace("`", "").strip()
                    break
            
            if filepath and (filepath.endswith("/ads_screen.dart") or filepath.endswith("\\ads_screen.dart")):
                # Extract lines
                in_code = False
                for l in content.split("\n"):
                    if "include a line number before every line" in l or "Showing lines" in l:
                        in_code = True
                        continue
                    if in_code:
                        if "The above content" in l or "does NOT show the entire" in l:
                            break
                        parts = l.split(":", 1)
                        if len(parts) == 2 and parts[0].strip().isdigit():
                            line_num = int(parts[0].strip())
                            line_val = parts[1][1:]
                            
                            if "ads_screen.dart" not in file_lines:
                                file_lines["ads_screen.dart"] = {}
                            file_lines["ads_screen.dart"][line_num] = line_val

if "ads_screen.dart" in file_lines:
    lines_map = file_lines["ads_screen.dart"]
    sorted_nums = sorted(lines_map.keys())
    print(f"Total unique lines captured for ads_screen.dart: {len(sorted_nums)}")
    print(f"Lines captured range: {min(sorted_nums)} to {max(sorted_nums)}")
else:
    print("No lines captured for ads_screen.dart.")
