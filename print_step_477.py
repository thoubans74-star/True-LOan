import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        
        if step_index == 477:
            print("STEP 477 keys:", list(data.keys()))
            print("Status:", data.get("status"))
            content = data.get("content", "")
            # Print search matches if present
            # Content is JSON formatted string or plain text of grep search output
            try:
                content_data = json.loads(content)
                print("Content JSON matches count:", len(content_data))
                for match in content_data[:10]:
                    print(match)
            except:
                print("Content text (first 1000 chars):")
                print(content[:1000])
