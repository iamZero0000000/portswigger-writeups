# Lab: SQL injection vulnerability allowing login bypass

- **Topic:** SQL Injection
- **Difficulty:** Apprentice
- **Date:** 24-05-2026
- **Status:** ✅ Solved

---

## What was the vulnerability?
SQL injection in the login form username field. The app directly concatenated user input into the authentication query without sanitization, allowing an attacker to manipulate the SQL logic.

---

## How did I find it?
Intercepted the login POST request in Burp Suite. Identified username and password parameters in the request body. Injected SQL comment sequence into the username field to bypass password verification.

---

## Payload used

```
username: administrator'--
password: anything
```

---

## Why did it work?
The app built the query like this:
```sql
SELECT * FROM users WHERE username = 'administrator'--' AND password = 'anything'
```
The -- commented out the password check entirely. Database returned the administrator user without verifying the password.

---

## What would fix it?
Parameterized queries. The password check should never be removable by user input. Input should be passed as data, never as part of the SQL structure.

---

## Key takeaway
SQL comment sequences can remove entire conditions from authentication queries. Never trust user input in SQL strings — always use prepared statements.
