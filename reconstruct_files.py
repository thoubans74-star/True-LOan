import json
import os

transcript_path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
active_dir = r"c:\Users\ELCOT\StudioProjects\tm\lib"

# Load files from active lib folder
in_memory_files = {}
for root, dirs, files in os.walk(active_dir):
    for file in files:
        full_path = os.path.join(root, file)
        rel_path = os.path.relpath(full_path, active_dir)
        # Store with prefix "lib\" to match transcript path formats
        key_path = os.path.join("lib", rel_path)
        with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
            in_memory_files[key_path] = f.read()

print(f"Loaded {len(in_memory_files)} files from active lib/ as base.")

# 2. Parse transcript line-by-line and replay edits
with open(transcript_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

def normalize_path(path_str):
    if not path_str:
        return ""
    path_str = path_str.replace("`file:///", "").replace("`", "").strip()
    if path_str.startswith("c:\\Users\\ELCOT\\StudioProjects\\tm\\"):
        path_str = path_str.replace("c:\\Users\\ELCOT\\StudioProjects\\tm\\", "")
    elif path_str.startswith("c:/Users/ELCOT/StudioProjects/tm/"):
        path_str = path_str.replace("c:/Users/ELCOT/StudioProjects/tm/", "")
    return path_str.replace("/", "\\")

def is_step_successful(lines_list, planner_step_index):
    for line in lines_list:
        data = json.loads(line)
        if data.get("step_index") == planner_step_index + 1:
            if data.get("status") == "DONE":
                return True
    return False

def replace_in_range(content, target_content, replacement_content, start_line, end_line):
    file_lines = content.splitlines(keepends=True)
    start_idx = max(0, start_line - 1)
    end_idx = min(len(file_lines), end_line)
    
    range_lines = file_lines[start_idx:end_idx]
    range_content = "".join(range_lines)
    
    if target_content in range_content:
        new_range_content = range_content.replace(target_content, replacement_content, 1)
    else:
        target_lf = target_content.replace("\r\n", "\n")
        range_lf = range_content.replace("\r\n", "\n")
        if target_lf in range_lf:
            new_range_content_lf = range_lf.replace(target_lf, replacement_content.replace("\r\n", "\n"), 1)
            new_range_content = new_range_content_lf
        else:
            return None
            
    before_lines = file_lines[:start_idx]
    after_lines = file_lines[end_idx:]
    return "".join(before_lines) + new_range_content + "".join(after_lines)

edit_count = 0
for idx, line in enumerate(lines):
    data = json.loads(line)
    step_index = data.get("step_index")
    step_type = data.get("type")
    
    # Only replay first branch edits (<= 883)
    if step_index > 883:
        continue
        
    if step_type == "PLANNER_RESPONSE":
        tool_calls = data.get("tool_calls", [])
        if not tool_calls:
            continue
            
        for tc in tool_calls:
            name = tc.get("name")
            args = tc.get("args", {})
            
            if name == "replace_file_content":
                if is_step_successful(lines, step_index):
                    target_file = normalize_path(args.get("TargetFile", ""))
                    target_content = args.get("TargetContent", "")
                    replacement_content = args.get("ReplacementContent", "")
                    start_line = args.get("StartLine", 1)
                    end_line = args.get("EndLine", 1)
                    
                    if target_file in in_memory_files:
                        content = in_memory_files[target_file]
                        if start_line == 1 and end_line == 1:
                            end_line = len(content.splitlines())
                            
                        new_content = replace_in_range(content, target_content, replacement_content, start_line, end_line)
                        if new_content is not None:
                            in_memory_files[target_file] = new_content
                            edit_count += 1
                            print(f"Step {step_index} | Replaced in {target_file} (lines {start_line}-{end_line})")
                        else:
                            if target_content in content:
                                in_memory_files[target_file] = content.replace(target_content, replacement_content, 1)
                                edit_count += 1
                                print(f"Step {step_index} | Replaced in whole file {target_file}")
                            else:
                                print(f"WARNING: Step {step_index} | TargetContent not found in {target_file}!")
                    else:
                        print(f"WARNING: Step {step_index} | File {target_file} not in base!")
                        
            elif name == "multi_replace_file_content":
                if is_step_successful(lines, step_index):
                    target_file = normalize_path(args.get("TargetFile", ""))
                    chunks = args.get("ReplacementChunks", [])
                    
                    if target_file in in_memory_files:
                        content = in_memory_files[target_file]
                        success = True
                        for chunk in chunks:
                            target_content = chunk.get("TargetContent", "")
                            replacement_content = chunk.get("ReplacementContent", "")
                            start_line = chunk.get("StartLine", 1)
                            end_line = chunk.get("EndLine", 1)
                            
                            if start_line == 1 and end_line == 1:
                                end_line = len(content.splitlines())
                                
                            new_content = replace_in_range(content, target_content, replacement_content, start_line, end_line)
                            if new_content is not None:
                                content = new_content
                            else:
                                if target_content in content:
                                    content = content.replace(target_content, replacement_content, 1)
                                else:
                                    print(f"WARNING: Step {step_index} | Multi-replace chunk TargetContent not found in {target_file} (lines {start_line}-{end_line})!")
                                    success = False
                        if success:
                            in_memory_files[target_file] = content
                            edit_count += 1
                            print(f"Step {step_index} | Multi-replaced in {target_file}")
                    else:
                        print(f"WARNING: Step {step_index} | File {target_file} not in base!")
                        
            elif name == "write_to_file":
                if is_step_successful(lines, step_index):
                    target_file = normalize_path(args.get("TargetFile", ""))
                    code_content = args.get("CodeContent", "")
                    
                    if target_file.startswith("lib\\"):
                        in_memory_files[target_file] = code_content
                        edit_count += 1
                        print(f"Step {step_index} | Wrote to file {target_file}")

print(f"Replay completed. Total successful edits replayed: {edit_count}")

# 3. Write replayed files directly to active lib directory (overwriting only modified files)
for rel_path, content in in_memory_files.items():
    # Only write back if it's inside lib folder
    dest_path = os.path.join(active_dir, rel_path.replace("lib\\", ""))
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    with open(dest_path, "w", encoding="utf-8") as out:
        out.write(content)

print("Replayed edits written back to active lib folder successfully.")
