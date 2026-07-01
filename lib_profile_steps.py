import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if step_type == "PLANNER_RESPONSE" and step_index <= 883:
            tool_calls = data.get("tool_calls", [])
            for tc in tool_calls:
                args = tc.get("args", {})
                target_file = args.get("TargetFile", "")
                if "profile.dart" in target_file:
                    print(f"Step {step_index} | Tool: {tc.get('name')}")
