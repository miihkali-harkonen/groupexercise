

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

-- 2.3 Monthly breakdown of the number of orders 
and total sales
SELECT
	DATE_TRUNC('month', orders.order_date)::DATE as month,
	COUNT(orders.order_id) AS total_orders,
	SUM(order_items.quantity * order_items.price_at_purchase) AS total_sales
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY month
ORDER BY month DESC;

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

-- visualization of top product sales 5.3
    SELECT 
        product_id,
        SUM(quantity * price_at_purchase) AS product_revenue,
        PERCENT_RANK() OVER (
			ORDER BY SUM(quantity * price_at_purchase) DESC
			) AS sales_rank
    FROM order_items
    GROUP BY product_id;

-- check 5.3
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
    SUM(product_revenue) FILTER (
        WHERE sales_rank <= 0.10) AS top_10_percent_revenue,
    SUM(product_revenue) AS total_revenue,
    ROUND(
        SUM(product_revenue) FILTER (WHERE sales_rank <= 0.10) / 
        SUM(product_revenue), 3) * 100 AS percentage_contribution
FROM product_sales;