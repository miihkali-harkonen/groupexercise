SELECT COUNT(*)
FROM orders

SELECT SUM(quantity * price_at_purchase)
FROM order_items