import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        
        if step_index == 563:
            print("STEP 563 details:")
            print("Status:", data.get("status"))
            content = data.get("content", "")
            print("Content (first 1000 chars):")
            print(content[:1000])
