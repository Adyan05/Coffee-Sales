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

-- 24)Customers spending above the customer average
-- customers whose lifetime revenue exceeds the average lifetime revenue of purchasing customers
with customer_spend AS (
SELECT customerid, customername, SUM(sales) AS revenue
FROM orders
GROUP BY customerid, customername)
SELECT *
FROM customer_spend
WHERE revenue > ( 
	SELECT AVG(revenue)
	FROM customer_spend
)

-- 25) Customer purchase-frequency segments
-- revenue and customer counts for Never purchased, One order, Two–three orders, and Four-plus orders segments
WITH customer_metric AS(
	SELECT cust.customerid, 
			cust.customername, 
			COUNT(DISTINCT ord.orderid) AS order_count, 
			COALESCE(SUM(ord.sales),0) AS revenue
	FROM customers cust
	LEFT JOIN orders ord
	ON cust.customerid=ord.customerid
	GROUP BY cust.customerid, cust.customername
),
customer_segments AS (
	SELECT customerid,
			revenue,
			CASE
			WHEN order_count=0 THEN 'Never Purchased'
			WHEN order_count=1 THEN 'One Order'
			WHEN order_count=2 THEN 'Two Orders'
			WHEN order_count=3 THEN 'Three Order'
			ELSE 'Four-plus Orders'
		END as Segment
	FROM customer_metric
)
SELECT segment, COUNT(*) AS customer_count, SUM(revenue) as revenue
FROM customer_segments
GROUP BY segment

-- 26) Customers inactive for at least 180 days
-- previous buyers whose last order was at least 180 days before August 19, 2022, including lifetime revenue
with customer_last_order AS(
	SELECT customerid, customername, MAX(orderdate) AS last_order, SUM(sales) AS revenue
	FROM orders
	GROUP BY customerid, customername
 	)
SELECT customerid, customername, last_order, revenue, DATE '2022-08-19' - last_order AS days_since_last_purchase
FROM customer_last_order
WHERE DATE '2022-08-19' - last_order >= 180
ORDER BY revenue DESC

-- 27) Products priced above their peers
-- products priced above the average for their own coffee type and package size
SELECT prod.productid, prod.coffeetype, prod.unitprice, prod.size
FROM products prod
WHERE unitprice > (
	SELECT AVG(peer.unitprice) 
	FROM products peer
	WHERE peer.coffeetype=prod.coffeetype AND peer.size=prod.size
)

-- 28) Customers who have bought both Arabica and Robusta
SELECT cust.customerid, cust.customername
FROM customers cust
WHERE EXISTS ( 
	SELECT 1
	FROM orders ord
	JOIN products prod
	ON ord.productid = prod.productid 
	WHERE cust.customerid = ord.customerid AND prod.coffeetype LIKE 'Ara'
	)
AND EXISTS (
	SELECT 1
	FROM orders ord
	JOIN products prod
	ON ord.productid = prod.productid 
	WHERE cust.customerid = ord.customerid AND prod.coffeetype LIKE 'Rob'
	)

-- 29) Return within 90 days of first purchase
-- percentage of first-time buyers who placed another order within 90 days, grouped by first-purchase month
WITH order_events AS(
	SELECT DISTINCT customerid,customername, orderid, orderdate
	FROM orders
	),
first_purchase AS(
	SELECT customerid, MIN(orderdate) AS first_purchase_date
	FROM order_events
	GROUP BY customerid
)
, first_flags AS (
	SELECT fp.customerid, fp.first_purchase_date,
	CASE WHEN (
			SELECT COUNT(DISTINCT oe.orderid)
			FROM order_events oe
			WHERE oe.customerid=fp.customerid
			AND oe.orderdate::date BETWEEN
			fp.first_purchase_date::date AND fp.first_purchase_date::date + 90)
			>=2 THEN 1
			ELSE 0
		END AS returned_within_90days
	FROM first_purchase fp
	WHERE fp.first_purchase_date::date <= DATE '2022-08-19' - 90
	)
SELECT DATE_TRUNC('month', first_purchase_date)::date AS first_purchase_month,
		COUNT(*) AS eligible_customers, 
		SUM(returned_within_90days) AS returning_customers,
		ROUND(100.0 * SUM(returned_within_90days)/COUNT(*),2) AS repeat_purchase_rate_pct
FROM first_flags
GROUP BY DATE_TRUNC('month', first_purchase_date)::date
ORDER BY first_purchase_month
FROM first_flags

-- 30)Seasonal revenue patterns
-- calendar months that repeatedly generate stronger revenue during 2019–2021
WITH SELECT SUM(sales) AS monthly_revenue, DATE_TRUNC('month',orderdate)::date AS sales_month
FROM orders
WHERE orderdate >= '2019-01-01' AND orderdate < '2022-01-01'
GROUP BY DATE_TRUNC('month',orderdate)::date
ORDER BY sales_month

-- 31) Customer revenue leaderboard
-- purchasing customers ranked by lifetime revenue, with equal revenue receiving equal rank
WITH customer_revenue AS(
	SELECT customerid, customername, SUM(sales) AS revenue
	FROM orders
	GROUP BY customerid, customername
)
SELECT *, RANK() OVER (ORDER BY revenue DESC) AS customer_rank
FROM customer_revenue
ORDER BY customer_rank, customerid

-- 32) Top three products within each country
-- products in the top three revenue ranks within each country, including ties.
WITH country_product_revenue AS(
	SELECT SUM(ord.sales) AS revenue, ord.productid, ord.coffeetypename, cust.country
	FROM orders ord
	JOIN products prod
	ON ord.productid=prod.productid
	JOIN customers cust 
	ON cust.customerid=ord.customerid
	GROUP BY ord.productid, ord.coffeetypename, cust.country
),
ranked_product AS(
	SELECT *, RANK() OVER (
					PARTITION BY country
					ORDER BY revenue DESC
	) AS product_rank
	FROM country_product_revenue
	)
SELECT * 
FROM ranked_product
WHERE product_rank <= 3
ORDER BY country, product_rank, productid, coffeetypename

-- 33) Exactly three products per coffee type
-- three feature slots per coffee type and wants the highest-revenue products
with product_revenue AS(
	SELECT productid, coffeetypename, SUM(sales) as revenue
	FROM orders
	GROUP BY productid, coffeetypename
	),
rank_coffee AS(
	SELECT *, 
			ROW_NUMBER() OVER (
							PARTITION BY coffeetypename 
							ORDER BY revenue DESC, productid) AS product_position
	FROM product_revenue
)
SELECT * 
FROM rank_coffee
WHERE product_position <= 3
ORDER BY coffeetypename, product_position

-- 34) Purchase-frequency ranking with real ties
-- purchasing customers ranked by distinct order count and wants to 
-- understand competition ranks versus consecutive frequency tiers
WITH customer_order AS(
	SELECT COUNT(DISTINCT orderid) AS order_count, customerid
	FROM orders
	GROUP BY customerid
)
SELECT *, RANK() OVER (ORDER BY order_count DESC) AS customer_rank,
		DENSE_RANK() OVER (ORDER BY order_count DESC) AS dense_customer_rank
FROM customer_order
ORDER BY customer_rank, customerid

-- 35) Product revenue contribution
-- each product’s percentage of its country’s revenue
with product_sale AS(
	SELECT SUM(sales) AS revenue, productid, country
	FROM orders
	GROUP BY productid, country
)
SELECT *, ROUND( 100.0 * revenue/ NULLIF(SUM(revenue) OVER (PARTITION BY country),0),2) as revenue_percentage
FROM product_sale
ORDER BY country, revenue_percentage DESC

-- 36) Revenue accumulated through the year
-- monthly revenue and year-to-date running revenue for each year
WITH monthly_rev AS (
	SELECT DATE_TRUNC('month', orderdate)::date AS sales_month, 
			SUM(sales) AS monthly_revenue
	FROM orders
GROUP BY DATE_TRUNC('month', orderdate)::date 

-- 37) Three-month moving-average revenue
WITH monthly_sales AS(
	SELECT SUM(sales) AS revenue, DATE_TRUNC('month', orderdate)::date as sales_month
	FROM orders 
	WHERE orderdate < DATE '2022-08-01'
	GROUP BY DATE_TRUNC('month', orderdate)::date
)
SELECT sales_month, 
		revenue, 
		CASE WHEN COUNT(*) OVER (
						ORDER BY sales_month
						ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
						) = 3
			THEN ROUND(AVG(revenue) OVER (
								ORDER BY sales_month
								ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
								),2)
			END AS three_month_moving_average
		FROM monthly_sales
		ORDER BY sales_month

-- 38) Month-over-month and year-over-year growth
-- monthly revenue compared with both the previous month and the same month a year earlier
WITH monthly_sales AS (
	SELECT SUM(sales) AS revenue, DATE_TRUNC('month', orderdate)::date AS sales_month
	FROM orders
	WHERE orderdate < DATE '2022-08-01'
	GROUP BY DATE_TRUNC('month', orderdate)::date
), revenue_comparison AS (
	SELECT sales_month, 
			revenue, 
			LAG(revenue, 1) OVER(
							ORDER by sales_month
			) AS prev_month_rev, 
			LAG(revenue, 12) OVER(
							ORDER by sales_month
			) AS prev_year_rev
	FROM monthly_sales
)
SELECT *, ROUND(100.0 * (revenue-prev_month_rev)/NULLIF(prev_month_rev,0),2) AS Month_over_month_growth_percentage,
		ROUND(100.0 * (revenue-prev_year_rev)/NULLIF(prev_year_rev,0),2) AS Year_over_Year_growth_percentage
FROM revenue_comparison
ORDER BY sales_month


-- 39) Customer purchase history and next purchase
-- each customer’s order sequence, previous and next purchase dates, and days between purchases
WITH order_events AS (
	SELECT orderid, customerid, orderdate, SUM(sales) AS revenue
	FROM orders
	GROUP BY customerid, orderid, orderdate
),
purchase_history AS(
	SELECT *, 
		ROW_NUMBER() OVER (
					PARTITION BY customerid
					ORDER BY orderdate, orderid
		) AS purchase_number,
		LAG(orderdate) OVER (
					PARTITION BY customerid
					ORDER BY orderdate, orderid
		) AS previous_purchase_date,
		LEAD(orderdate) OVER (
					PARTITION BY customerid
					ORDER BY orderdate, orderid
		) AS next_purchase_date
	FROM order_events
		)
	SELECT *,
			orderdate-previous_purchase_date AS days_since_previous_purchase,
			next_purchase_date - orderdate AS days_until_next_purchase
	FROM purchase_history
	ORDER BY customerid, purchase_number DESC

-- 40) Unusually large orders for each customer\
-- orders worth at least 50% more than that customer’s average order value, limited to customers with at least three orders
WITH order_totals AS(
	SELECT orderid, customerid, SUM(sales) as revenue
	FROM orders
	GROUP BY orderid, customerid
), customer_benchmark AS (
	SELECT *, AVG(revenue) OVER (
						PARTITION BY customerid
						) AS customer_average_order_value,
						COUNT(*) OVER(
						PARTITION BY customerid
						) AS order_count
				FROM order_totals
	)
SELECT customerid, orderid, revenue, ROUND(customer_average_order_value,2) AS customer_average_order_value, order_count
FROM customer_benchmark
WHERE order_count >=3
AND revenue >= customer_average_order_value * 1.5
ORDER BY customerid, revenue DESC

