# Lab: Blind SQL injection with conditional errors

- **Topic:** SQL Injection
- **Difficulty:** Practitioner
- **Date:** 24-05-2026
- **Status:** ✅ Solved

---

## What was the vulnerability?
Blind SQL injection in TrackingId cookie on an Oracle database. No visible response difference existed but HTTP status codes changed based on whether a database error was triggered — allowing error-based blind extraction.

---

## How did I find it?
Confirmed Oracle database by requirement for FROM dual syntax. Used CASE WHEN to conditionally trigger divide-by-zero errors. 500 status = condition true, 200 status = condition false.

---

## Payload used

```sql
-- Confirm conditional errors work
TrackingId=xyz' AND (SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE 'a' END FROM dual)='a
-- Returns 500

TrackingId=xyz' AND (SELECT CASE WHEN (1=2) THEN TO_CHAR(1/0) ELSE 'a' END FROM dual)='a  
-- Returns 200

-- Extract password character by character
xyz' AND (SELECT CASE WHEN (SUBSTR(password,1,1)='a') THEN TO_CHAR(1/0) ELSE 'a' END FROM users WHERE username='administrator')='a
```

---

## Why did it work?
Oracle executed the CASE expression and when the condition was true, attempted 1/0 causing an unhandled divide-by-zero error returned as HTTP 500. When false it returned 'a' safely giving HTTP 200. Status code became the yes/no oracle.

---

## Tools used
Modified Python script to check `response.status_code == 500` instead of text content. Used Oracle-specific SUBSTR and TO_CHAR syntax.

---

## What would fix it?
Parameterized queries. Also handle database errors gracefully — never let raw database errors propagate to HTTP responses.

---

## Key takeaway
When no text difference exists, HTTP status codes can still leak boolean information. Oracle requires TO_CHAR(1/0) for conditional errors unlike other databases that use plain 1/0.
