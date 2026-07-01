import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        created_at = data.get("created_at")
        
        # Print all PLANNER_RESPONSE step indices and their timestamps up to step 1022
        if step_type == "PLANNER_RESPONSE" and step_index < 1022:
            thinking = data.get("thinking", "")
            summary = thinking.split("\n")[0][:80] if thinking else ""
            print(f"Step {step_index} | {created_at} | {summary}")
