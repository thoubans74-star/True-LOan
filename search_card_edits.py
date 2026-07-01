import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if step_type == "PLANNER_RESPONSE" and data.get("status") == "DONE":
            for tc in data.get("tool_calls", []):
                args = tc.get("args", {})
                target = args.get("TargetFile", "")
                if "new_home" in target and any(x in target for x in ["home_loan.dart", "personal_loan.dart", "vehicle_loan.dart", "bussiness_loan.dart"]):
                    print(f"Step {step_index} | Tool: {tc.get('name')} | Target: {target}")
                    print(f"  Args: {list(args.keys())}")
                    for k, v in args.items():
                        if k in ["ReplacementChunks", "ReplacementContent", "TargetContent"]:
                            print(f"    {k}: {v[:300]}")
                    print("-" * 50)
print("Done.")
