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

-- 9) Executive sales snapshot
-- total revenue, units sold, distinct orders, and purchasing customers for the entire dataset.
SELECT SUM(sales) as total_revenue, SUM(quantity) as units_sold, COUNT(DISTINCT orderid) AS distinct_orders, COUNT(DISTINCT customerid) as purchasing_customers
FROM orders

-- 10) Average Order Value
-- average amount customers spend per order
SELECT ROUND (SUM(sales) / NULLIF(COUNT(DISTINCT orderid),0), 2) AS Average_Order_Value 
FROM orders

-- 11) Transaction coverage and range
-- earliest and latest sale dates, minimum and maximum sales-line values, and average units per sales line.
SELECT MIN(orderdate) AS earliest_sale_date, MAX(orderdate) AS latest_sale_date, MIN(sales) AS min_sales, MAX(sales) AS max_sales, ROUND(AVG(quantity),2) AS average_units_per_sales
FROM orders

-- 12) Monthly sales scorecard
-- monthly revenue, order counts, and units sold
SELECT DATE_TRUNC('month', orderdate)::date  AS SalesMonth, SUM(sales) AS MonthlyRevenue, COUNT(DISTINCT orderid) AS OrderCounts, SUM(quantity) AS UnitsSold
FROM orders
GROUP BY SalesMonth
ORDER BY SalesMonth

-- 13) Coffee-type performance
-- which coffee types lead in revenue and which lead in units
SELECT SUM(sales) AS revenue, SUM(quantity) units_sold, coffeetypename
FROM orders
GROUP BY coffeetypename
ORDER BY revenue DESC

-- 14) Roast and package preferences
-- revenue and units for each roast-type and package-size combination.
SELECT SUM(sales) AS revenue, SUM(quantity) AS units, roasttypename, size
FROM orders
GROUP BY roasttypename, size

-- 15) Country performance
-- revenue, orders, purchasing customers, and AOV for each country.
SELECT country, SUM(sales) AS revenue, COUNT(DISTINCT orderid), COUNT(DISTINCT customerid) , ROUND(SUM(sales)/ COUNT(DISTINCT orderid),2) AS AverageOrderValue
FROM orders
GROUP by country

-- 16) Products with meaningful sales volume
-- products that sold at least 50 units, ordered by revenue.
SELECT productid, SUM(sales) AS revenue, SUM(quantity) units_sold
FROM orders
GROUP BY productid
HAVING SUM(quantity) >= 50
ORDER BY revenue