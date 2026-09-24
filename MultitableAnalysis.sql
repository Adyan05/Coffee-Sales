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

-- 17) Customer purchase lookup
-- sales lines with customer names, countries, and contact details.
SELECT ord.customerid, ord.orderdate, ord.orderid, ord.productid, ord.sales, ord.quantity, cust.customername, cust.country, cust.phonenumber, cust.email
FROM orders ord
JOIN customers cust ON ord.customerid= cust.customerid

-- 18) Customers who have never purchased
--  registered customers with no recorded orders 
SELECT cust.customerid, cust.customername
FROM customers cust
JOIN orders ord ON cust.customerid=ord.customerid
WHERE ord.orderid IS NULL 

-- 19) Complete customer value directory
-- every customer listed with revenue and distinct order count, including customers with no purchases
SELECT cust.customerid, cust.customername, COUNT(DISTINCT ord.orderid) AS OrderCount, COALESECE(SUM(ord.Sales),0) AS Revenue
FROM customers cust
LEFT JOIN orders ord ON cust.customerid=ord.customerid
GROUP BY cust.customerid, cust.customername

-- 20) Estimated product profitability
-- each product’s units, revenue, estimated total profit, and estimated profit margin
WITH product_info AS(
SELECT ord.productid, SUM(ord.quantity) AS units_sold, SUM(ord.sales) as revenue, SUM(ord.quantity*prod.profit) AS estimated_total_profit
FROM orders ord
JOIN products prod ON ord.productid=prod.productid 
GROUP BY ord.productid
)
SELECT productid, units_sold, revenue, ROUND(estimated_total_profit,2) AS estimated_total_profit , ROUND(100*estimated_total_profit/NULLIF(revenue,0),2) AS estimated_profit_margin
FROM product_info