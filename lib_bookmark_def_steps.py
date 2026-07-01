import json

path = r"C:\Users\ELCOT\.gemini\antigravity-ide\brain\30633281-5810-4010-bb0f-4360a52afafa\.system_generated\logs\transcript_full.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        step_index = data.get("step_index")
        step_type = data.get("type")
        
        # Check if class BookmarksScreen or class BookmarkManager is in the JSON text
        text = json.dumps(data)
        if "class BookmarksScreen" in text or "class BookmarkManager" in text:
            print(f"Step {step_index} | Type: {step_type}")
            # print first 200 chars of matching text
            idx = text.find("class BookmarksScreen")
            if idx != -1:
                print("  BookmarksScreen snippet:", text[idx:idx+150])
            idx2 = text.find("class BookmarkManager")
            if idx2 != -1:
                print("  BookmarkManager snippet:", text[idx2:idx2+150])
