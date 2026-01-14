---4.1.1 Total number of orders----
SELECT COUNT(*) AS Total_number_of_orders
FROM orders;

---4.1.2 Total sales-----
SELECT SUM(quantity * price_at_purchase) AS Total_sales
FROM order_items

-----4.4.2 orders above certain threshold-----
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

-------4.4.3- orders with highest number of items ------

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





