SELECT 
    DATE_TRUNC('month', orders.order_date)::DATE as month,
    ROUND(AVG(shipments.delivery_date - orders.order_date), 2) AS avg_delivery_days
FROM orders
JOIN shipments ON orders.order_id = shipments.order_id
GROUP BY month
ORDER BY month DESC;