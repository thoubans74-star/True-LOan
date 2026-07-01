import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        # Check if ads_screen.dart is in the JSON text
        if "ads_screen.dart" in json.dumps(data):
            print(f"Step {step_index} | Type: {step_type}")
            if step_type == "PLANNER_RESPONSE":
                print("  Tool calls:", [tc.get("name") for tc in data.get("tool_calls", [])])
                for tc in data.get("tool_calls", []):
                    args = tc.get("args", {})
                    target = args.get("TargetFile", "")
                    if "ads_screen.dart" in target:
                        print(f"    Args: {list(args.keys())}")
