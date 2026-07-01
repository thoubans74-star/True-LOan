import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        if "class MarketUser" in json.dumps(data):
            print(f"Step {step_index} | Type: {step_type}")
            text = json.dumps(data)
            idx = text.find("class MarketUser")
            print("  Snippet:", text[max(0, idx-50):min(len(text), idx+150)])
            print("-" * 40)
