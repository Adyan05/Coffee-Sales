-- Initial check
SELECT * 
FROM orders

SELECT * 
FROM customers

SELECT * 
FROM products

-- Customer Revenue
DROP VIEW IF EXISTS customer_revenue;
CREATE VIEW customer_revenue AS
SELECT SUM(sales) AS revenue, 
		SUM(quantity) AS units_sold, 
		customerid 
FROM orders
GROUP BY customerid


--1) Recent Sales Review
--20 most recent sales
SELECT orderid, orderdate, customerid, productid, quantity, sales
FROM orders
ORDER BY orderdate DESC, orderid, productid
LIMIT 20;

-- 2) Countries Represented in the Customer Base
SELECT DISTINCT country
FROM customers
ORDER BY country ASC


-- 3) Quarterly sales inspection	
-- inspect sales lines recorded during the first quarter of 2021.
SELECT orderdate, sales
FROM orders 
WHERE orderdate >= '2021-01-01' AND orderdate < '2021-04-01'
ORDER BY orderdate ASC

-- 4) Selected-market sales
-- all sales lines from Ireland and the United Kingdom during 2021.
SELECT orderdate, sales, country
FROM orders
WHERE orderdate >= '2021-01-01' AND orderdate < '2022-01-01' AND Country IN ('Ireland', 'United Kingdom');

-- 5) Email-provider review
-- identify customers whose recorded email addresses use Gmail
SELECT customername, email, COUNT(*) AS gmail_customers
FROM customers
WHERE email ILIKE '%@gmail.com'
GROUP BY customername, email

-- 6) Missing contact information
-- a list of customers missing an email address, with a readable “Missing email” label.
SELECT customername, COALESCE(NULLIF(TRIM(email),''), 'Missing Email') AS empty_email
FROM customers
WHERE NULLIF(TRIM(email),'') IS NULL

-- 7) Sales-line value bands
-- each sales line labeled Small, Medium, or Large for a manual review queue.
SELECT sales, coffeetypename, customername,
CASE 
	WHEN sales < 20 THEN 'Small Sale'
	WHEN sales >= 20 AND sales < 50 THEN 'Medium Sale'
	WHEN sales >= 50 THEN 'High Sale'
	END AS sales_category
FROM orders

-- 8) Affordable product shortlist
-- five lowest-priced products that cost at most 10 per unit.
SELECT productid, coffeetype, unitprice
FROM products
WHERE unitprice <= 10
ORDER BY unitprice ASC, productid ASC
LIMIT 5

