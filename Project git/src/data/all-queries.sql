"""
    ASSIGNMENT 4 - Analytical queries
"""

-- 1.1 Total number of orders.
SELECT COUNT(*) AS Total_number_of_orders
FROM orders;

-- 1.2 Total sales.
SELECT SUM(quantity * price_at_purchase) AS Total_sales
FROM order_items;

-- 1.3. Count of products with low stock (e.g.,stock_quantity < 10).
SELECT COUNT(*) AS low_stock_products
FROM products
WHERE stock_quantity < 10;

-- 2.1 Total sales per product category.
SELECT
	products.category,
	ROUND(SUM(order_items.quantity * order_items.price_at_purchase), 2) as total_sales
FROM
	products
JOIN order_items ON order_items.product_id = products.product_id 
GROUP BY
	products.category
ORDER BY total_sales DESC;


-- 2.2. Average order value.
SELECT AVG(total_order) AS avg_ord_val
FROM (SELECT order_id, SUM(quantity * price_at_purchase) AS total_order
FROM order_items
GROUP BY order_id)
AS sub;

-- 2.3 Monthly breakdown of the number of orders and total sales
SELECT
	DATE_TRUNC('month', orders.order_date)::DATE as month,
	COUNT(orders.order_id) AS total_orders,
	SUM(order_items.quantity * order_items.price_at_purchase) AS total_sales
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY month
ORDER BY month DESC;

-- 3.1 List of orders, with each order showing the customer's name and total order value.
SELECT
    orders.order_id, customers.cust_name,
    sum(order_items.price_at_purchase * order_items.quantity) AS total_order_value
FROM
    orders
JOIN
    customers ON orders.customer_id = customers.customer_id
JOIN
    order_items ON orders.order_id = order_items.order_id
GROUP BY
    orders.order_id, customers.cust_name
ORDER BY
    orders.order_id;

-- 3.2 Top 5 customers by total spending.
SELECT
    customers.cust_name,
    sum(order_items.price_at_purchase * order_items.quantity) AS total_order_value
FROM
    orders
JOIN
    order_items ON orders.order_id = order_items.order_id
JOIN
    customers ON orders.customer_id = customers.customer_id
GROUP BY
    customers.cust_name
ORDER BY
    total_order_value DESC
LIMIT 5;

-- 3.3 List of suppliers and the number of products they supply, 
--     ordered by the supplier with the most products.

SELECT
    suppliers.name,
    count(*) AS number_of_products
FROM
    suppliers
JOIN
    products ON products.supplier_id = suppliers.supplier_id
GROUP BY
    suppliers.name
ORDER BY
    number_of_products DESC;

SELECT
    product_id
FROM
    products
WHERE
    product_id NOT IN
    (
    SELECT
        products.product_id
    FROM
        products
    JOIN
        order_items ON order_items.product_id = products.product_id
    GROUP BY
        products.product_id
    ORDER BY
        products.product_id
    );


-- 4.1 Products that have never been ordered.
SELECT
    products.product_id,
    sum(order_items.quantity)
FROM
    products
JOIN
    order_items ON order_items.product_id = products.product_id
GROUP BY
    products.product_id
ORDER BY
    products.product_id;


-- 4.2 orders above certain threshold.
SELECT
    orders.order_id, customers.cust_name AS high_ordering_customers_5000,
    sum(order_items.price_at_purchase * order_items.quantity) AS total_order_value 	
FROM
    orders
JOIN
    customers ON orders.customer_id = customers.customer_id
JOIN
    order_items ON orders.order_id = order_items.order_id	
GROUP BY
    orders.order_id, customers.cust_name
HAVING
    SUM(order_items.price_at_purchase * order_items.quantity) > 5000
ORDER BY
    orders.order_id;

-- 4.3- orders with highest number of items.

WITH order_totals AS (
  SELECT orders.order_id, customers.cust_name, SUM(order_items.quantity) AS total_items
  FROM orders 
  JOIN order_items ON orders.order_id = order_items.order_id
  JOIN customers ON orders.customer_id = customers.customer_id
  GROUP BY orders.order_id, customers.cust_name
)
SELECT order_id, cust_name AS customer_name, total_items
FROM order_totals
WHERE total_items = (SELECT MAX(total_items) FROM order_totals);


-- 5.1. Trend in daily orders over time, identifying peak order days.
SELECT
    order_date,
    COUNT(*) AS daily_orders
FROM orders
WHERE order_status <> 'cancelled'
GROUP BY order_date
ORDER BY daily_orders DESC
LIMIT 10;


-- 5.2 Average delivery time per month.
SELECT 
    DATE_TRUNC('month', orders.order_date)::DATE AS month,
    ROUND(AVG(shipments.delivery_date - orders.order_date), 2) AS avg_delivery_days
FROM orders
JOIN shipments ON orders.order_id = shipments.order_id
GROUP BY month
ORDER BY month DESC;

-- 5.3 Percentage of total sales attributed to the top 10% of products by sales.

WITH product_sales AS (
    SELECT 
        product_id,
        SUM(quantity * price_at_purchase) AS product_revenue,
        PERCENT_RANK() OVER (
            ORDER BY SUM(quantity * price_at_purchase) DESC
        ) AS sales_rank
    FROM order_items
    GROUP BY product_id
)
SELECT 
    ROUND(
        SUM(product_revenue) FILTER (WHERE sales_rank <= 0.10) / 
        SUM(product_revenue), 3) * 100 AS percentage_contribution
FROM product_sales;


-- 5.3 Percentage of total sales attributed to the top 10% of products by sales.

WITH product_sales AS (
    SELECT 
        product_id,
        SUM(quantity * price_at_purchase) AS product_revenue,
        PERCENT_RANK() OVER (
            ORDER BY SUM(quantity * price_at_purchase) DESC
        ) AS sales_rank
    FROM order_items
    GROUP BY product_id
)
SELECT
    ROUND(
        SUM(product_revenue) FILTER (WHERE sales_rank <= 0.10) / 
        SUM(product_revenue), 3) * 100 AS percentage_contribution
FROM product_sales;

-- visualization of top product sales CTE 5.3
    SELECT 
        product_id,
        SUM(quantity * price_at_purchase) AS product_revenue,
        PERCENT_RANK() OVER (
			ORDER BY SUM(quantity * price_at_purchase) DESC
			) AS sales_rank
    FROM order_items
    GROUP BY product_id;

