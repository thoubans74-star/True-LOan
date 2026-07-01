import os
import time

sp_dir = r"C:\Users\ELCOT\StudioProjects"
for item in os.listdir(sp_dir):
    path = os.path.join(sp_dir, item)
    mtime = os.path.getmtime(path)
    print(f"Name: {item}")
    print(f"  Is Directory: {os.path.isdir(path)}")
    print(f"  Modified: {time.ctime(mtime)}")
    print("-" * 30)
