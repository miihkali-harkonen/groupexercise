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