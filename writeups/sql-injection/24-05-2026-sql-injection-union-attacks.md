# Lab: SQL injection UNION attacks

- **Topic:** SQL Injection
- **Difficulty:** Practitioner
- **Date:** 24-05-2026
- **Status:** ✅ Solved

---

## What was the vulnerability?
SQL injection in the category filter allowing UNION-based data extraction. The app returned query results directly in the response making it possible to retrieve data from other database tables.

---

## How did I find it?
Injected single quote into category parameter to confirm injection. Used NULL padding to find column count. Identified text-accepting columns. Then extracted data from users table.

---

## Payload used

```sql
-- Find column count
' UNION SELECT NULL,NULL--

-- Find text column
' UNION SELECT 'test',NULL--

-- Extract credentials
' UNION SELECT username,password FROM users--
```

---

## Why did it work?
The app reflected query results directly on the page. By matching column count and types with NULL padding, the UNION appended results from the users table to the normal output. Both username and password appeared on the product listing page.

---

## What would fix it?
Parameterized queries prevent injection. Additionally, results should never directly reflect raw database data without output encoding. Principle of least privilege — the DB user shouldn't have access to the users table from a product query.

---

## Key takeaway
UNION attacks require matching column count and data types. Always find column count with NULLs first, then find text columns, then extract data. Three steps every time.
