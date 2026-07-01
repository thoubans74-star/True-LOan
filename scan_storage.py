import re

path = r"C:\Users\ELCOT\AppData\Local\Google\AndroidStudio2025.3.3\LocalHistory\changes.storageData"
with open(path, "rb") as f:
    data = f.read()

# Let's search for readable ascii / utf-8 strings of dart code (e.g. import 'package:flutter or class HomeScreen)
# We can find contiguous blocks of printable characters
printable = re.compile(b'[a-zA-Z0-9_\\s(){}\\[\\]\'":;.,<>?=+!@#$%^&*|-]+')
matches = printable.findall(data)

# Let's count how many long matches we find
long_matches = [m for m in matches if len(m) > 100]
print(f"Found {len(long_matches)} text segments longer than 100 bytes.")
if long_matches:
    print("Example segment:")
    print(long_matches[0][:500].decode('ascii', errors='ignore'))
