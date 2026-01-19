-- 1.3. Count of products with low stock (e.g.,
-- stock_quantity < 10)
SELECT COUNT(*) AS low_stock_products
FROM products
WHERE stock_quantity < 10;

-- 2.2. Average order value.
SELECT AVG(total_order) AS avg_ord_val
FROM (SELECT order_id, SUM(quantity * price_at_purchase) AS total_order
FROM order_items
GROUP BY order_id)
AS sub;

-- 5.1. Trend in daily orders over time, identifying peak order
-- days.
SELECT
    order_date,
    COUNT(*) AS daily_orders
FROM orders
WHERE order_status <> 'cancelled'
GROUP BY order_date
ORDER BY daily_orders DESC
LIMIT 10;
