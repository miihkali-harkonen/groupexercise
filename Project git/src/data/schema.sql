-- schema.sql

DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;

-- one-many
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info TEXT,
    country VARCHAR(100) NOT NULL
);

-- one-many
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    supplier_id INT NOT NULL REFERENCES suppliers(supplier_id) ON DELETE RESTRICT,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    cust_name VARCHAR(50) NOT NULL,
    cust_location VARCHAR(50),
    cust_email VARCHAR(150) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(50) NOT NULL
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC(10, 2) NOT NULL CHECK (price_at_purchase >= 0)
);

CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    shipped_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    shipping_cost NUMERIC(10, 2) NOT NULL CHECK (shipping_cost >= 0),
    CHECK (delivery_date >= shipped_date)
);

-- What I have fixed:
-- Orders.order_id INT PRIMARY KEY → you’ll have to manually generate ids (okay), but it’s easier with SERIAL.
-- Order_Items has invalid FK syntax and is missing order_id and product_id columns.
-- Shipments has no order_id column, so it can’t be 1–1 (or even link to orders).
-- Table names mismatch: you used suppliers/products lowercase, but Customers/Orders/...
-- mixed-case. In Postgres, unquoted names become lowercase, so keep everything lowercase to avoid confusion.

--Relations:
-- suppliers → products (1–many)
-- customers → orders (1–many)
-- orders → order_items (1–many)
-- products → order_items (1–many)
-- orders → shipments (1–1 via UNIQUE(order_id))
