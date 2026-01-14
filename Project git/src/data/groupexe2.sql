select 
	AVG(price_at_purchase * quantity) AS average_order_value
FROM order_items;


SELECT
	DATE_TRUNC('month', orders.order_date)::DATE as month,
	COUNT(orders.order_id) AS total_orders,
	SUM(order_items.quantity * order_items.price_at_purchase) AS total_sales
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY month
ORDER BY month DESC;

