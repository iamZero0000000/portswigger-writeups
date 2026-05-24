# Lab: SQL injection with filter bypass via XML encoding

- **Topic:** SQL Injection
- **Difficulty:** Practitioner
- **Date:** 24-05-2026
- **Status:** ✅ Solved

---

## What was the vulnerability?
SQL injection in the storeId parameter of a stock check XML endpoint. A WAF blocked standard SQL keywords but XML entity encoding bypassed the filter while the server decoded and executed the payload normally.

---

## How did I find it?
Found POST /product/stock endpoint accepting XML body. Normal UNION SELECT was blocked with "Attack detected". Used XML hex encoding to obfuscate SQL keywords — WAF couldn't recognise them but the server decoded and passed them to the database.

---

## Payload used

```xml
<stockCheck>
    <productId>1</productId>
    <storeId>1 &#x55;&#x4E;&#x49;&#x4F;&#x4E; &#x53;&#x45;&#x4C;&#x45;&#x43;&#x54; username||'~'||password &#x46;&#x52;&#x4F;&#x4D; users&#x2D;&#x2D;</storeId>
</stockCheck>
```

Decoded: `1 UNION SELECT username||'~'||password FROM users--`

---

## Why did it work?
The WAF scanned for SQL keywords as plain text. XML encoding converted each character to its hex entity equivalent. WAF saw gibberish and allowed it through. The server decoded XML entities before passing to the database which executed the full UNION SELECT. Credentials appeared in the stock count response field.

---

## Tools used
Hackvertor Burp extension for automatic XML encoding. Also manually encoded specific characters to understand the technique.

---

## What would fix it?
WAF should normalise and decode input before scanning. Parameterized queries make WAF bypass irrelevant — even if the payload gets through, it can't manipulate the query structure.

---

## Key takeaway
WAFs are not a substitute for parameterized queries. Encoding bypasses show that any filter inspecting raw input can be evaded. Defense in depth is essential — WAF + parameterized queries + input validation together.
