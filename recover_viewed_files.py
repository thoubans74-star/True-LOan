import json
import os
import re

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"

file_lines = {}

with open(path, "r", encoding="utf-8") as f:
    for line_str in f:
        data = json.loads(line_str)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        # Only recover from steps up to step 883 (first branch)
        if step_index > 883:
            continue
            
        if step_type == "VIEW_FILE" and data.get("status") == "DONE":
            content = data.get("content", "")
            
            # Find file path
            filepath = None
            for l in content.split("\n"):
                if "File Path: " in l:
                    filepath = l.split("`file:///")[1].replace("`", "").strip()
                    if os.name == 'nt':
                        filepath = filepath.replace("/", "\\")
                    break
            
            if filepath:
                # We normalize the file path to be relative to workspace if possible
                norm_path = filepath
                if norm_path.startswith("c:\\Users\\ELCOT\\StudioProjects\\tm\\"):
                    norm_path = norm_path.replace("c:\\Users\\ELCOT\\StudioProjects\\tm\\", "")
                elif norm_path.startswith("c:/Users/ELCOT/StudioProjects/tm/"):
                    norm_path = norm_path.replace("c:/Users/ELCOT/StudioProjects/tm/", "")
                norm_path = norm_path.replace("/", "\\")
                
                # Now extract lines
                in_code = False
                for l in content.split("\n"):
                    if "include a line number before every line" in l or "Showing lines" in l:
                        in_code = True
                        continue
                    if in_code:
                        if "The above content" in l or "does NOT show the entire" in l:
                            break
                        # Line format: "1: code" or "10: code"
                        parts = l.split(":", 1)
                        if len(parts) == 2 and parts[0].strip().isdigit():
                            line_num = int(parts[0].strip())
                            line_val = parts[1][1:] # Strip the single leading space after colon
                            
                            if norm_path not in file_lines:
                                file_lines[norm_path] = {}
                            
                            file_lines[norm_path][line_num] = line_val
                        elif l.strip() == "" and in_code:
                            # It could be an empty line without prefix, but usually lines have numbers
                            pass

print(f"Parsed views for {len(file_lines)} files.")

# Reconstruct and write files that are in the lib/ folder
for rel_path, lines_map in file_lines.items():
    if not rel_path.startswith("lib\\"):
        continue
        
    # Sort line numbers
    sorted_line_nums = sorted(lines_map.keys())
    if not sorted_line_nums:
        continue
        
    # We might have gaps if some lines weren't viewed, but usually we viewed everything
    # Let's fill gaps with empty strings or check if there are gaps
    reconstructed_content = []
    max_line = max(sorted_line_nums)
    for i in range(1, max_line + 1):
        reconstructed_content.append(lines_map.get(i, ""))
        
    file_content = "\n".join(reconstructed_content)
    
    # Write to lib directory
    dest_path = os.path.join("lib", rel_path.replace("lib\\", ""))
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    
    with open(dest_path, "w", encoding="utf-8") as out:
        out.write(file_content)
        
    print(f"Recovered {rel_path} to {dest_path} with {len(reconstructed_content)} lines.")
