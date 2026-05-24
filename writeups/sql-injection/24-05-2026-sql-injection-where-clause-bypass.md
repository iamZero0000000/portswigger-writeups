## What was the vulnerability?
SQL injection in the category filter parameter. App directly 
concatenated user input into SQL query without sanitization.

## How did I find it?
Added single quote to category parameter in URL. Then used 
OR 1=1-- to make condition always true.

## Payload used
' OR 1=1--

## Why did it work?
The OR 1=1 made the WHERE condition always true returning 
all products. The -- commented out AND released=1 exposing 
unreleased products.

## What would fix it?
Parameterized queries instead of string concatenation.

## Key takeaway
SQL injection in WHERE clause can bypass business logic 
filters exposing hidden data.
