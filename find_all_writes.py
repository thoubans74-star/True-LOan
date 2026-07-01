import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if step_index > 883:
            continue
            
        if step_type == "PLANNER_RESPONSE":
            for tc in data.get("tool_calls", []):
                if tc.get("name") == "write_to_file":
                    args = tc.get("args", {})
                    target = args.get("TargetFile", "")
                    print(f"Step {step_index} | Wrote to: {target}")
