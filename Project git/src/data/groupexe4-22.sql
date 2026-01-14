SELECT
	ROUND(AVG(price_at_purchase * quantity), 2) AS average_order_value
FROM order_items;