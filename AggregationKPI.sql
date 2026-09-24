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