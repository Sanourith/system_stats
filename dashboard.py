# This script will automatically refresh the terminal dashboard with PC's stats.
import os
import time
import psutil


def clear():
    os.system("clear")


while True:
    clear()

    print("=== SYSTEM DASHBOARD ===")
    print()

    print(f"CPU     : {psutil.cpu_percent()}%")
    print(f"RAM     : {psutil.virtual_memory().percent}%")
    print(f"DISK    : {psutil.disk_usage('/').percent}%")
    print(f"UPTIME  : {time.time()}")

    print()
    print("Press ctrl+C to quit")
    time.sleep(1)
