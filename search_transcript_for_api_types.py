import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        
        # Convert data to string to search
        text = json.dumps(data)
        for api_type in ["1115", "1110", "1103", "1104"]:
            if api_type in text:
                print(f"Step {step_index} | Type: {data.get('type')} | Mentioned API type: {api_type}")
                # Print snippet
                idx = text.find(api_type)
                print("  Snippet:", text[max(0, idx-100):min(len(text), idx+150)])
                print("-" * 50)
                break
