import random
from datetime import timedelta
from faker import Faker
from psycopg2.extras import execute_values
from .queries import connect

fake = Faker()


def seed_database(
    num_suppliers=20,
    num_products=200,
    num_customers=1000,
    num_orders=1000,
    max_items_per_order=5,
    shipment_probability=0.8,
    seed=42,
):
    # Make deterministic for everyone
    random.seed(seed)
    Faker.seed(seed)

    conn = connect()
    if conn is None:
        print("Could not connect to database")
        return

    cur = conn.cursor()

    try:
        # Clear tables in FK-safe order
        cur.execute("""
            TRUNCATE TABLE shipments, order_items, orders, customers, products, suppliers
            RESTART IDENTITY CASCADE;
        """)
        conn.commit()

        # --- 1) Suppliers (small insert -> RETURNING is fine) ---
        suppliers = [
            (
                fake.company(),
                f"{fake.email()} | {fake.phone_number()} | {fake.address().replace(chr(10), ', ')}",
                fake.country(),
            )
            for _ in range(num_suppliers)
        ]

        execute_values(
            cur,
            "INSERT INTO suppliers (name, contact_info, country) VALUES %s RETURNING supplier_id;",
            suppliers,
        )
        supplier_ids = [r[0] for r in cur.fetchall()]

        # --- 2) Products (200 rows -> RETURNING is fine) ---
        categories = ["Grocery", "Electronics", "Home", "Sports", "Books", "Beauty", "Clothing"]
        products = []
        for _ in range(num_products):
            products.append(
                (
                    fake.word().capitalize() + " " + fake.word().capitalize(),
                    random.choice(categories),
                    round(random.uniform(5, 500), 2),
                    random.choice(supplier_ids),
                    random.randint(0, 1000),
                )
            )

        execute_values(
            cur,
            """
            INSERT INTO products (name, category, price, supplier_id, stock_quantity)
            VALUES %s
            RETURNING product_id, price;
            """,
            products,
        )

        product_rows = cur.fetchall()
        product_ids = [r[0] for r in product_rows]
        #Making sure some products will not have any orders linked
        product_ids = random.sample(product_ids, 90)
        product_price_map = {r[0]: float(r[1]) for r in product_rows}

        # --- 3) Customers (large insert -> NO RETURNING; SELECT back) ---
        customers = []
        used_emails = set()
        for _ in range(num_customers):
            email = fake.email()
            while email in used_emails:
                email = fake.email()
            used_emails.add(email)
            customers.append((fake.name(), fake.city(), email))

        execute_values(
            cur,
            "INSERT INTO customers (cust_name, cust_location, cust_email) VALUES %s;",
            customers,
        )

        cur.execute("SELECT customer_id FROM customers ORDER BY customer_id;")
        customer_ids = [r[0] for r in cur.fetchall()]

        # --- 4) Orders (large insert -> NO RETURNING; SELECT back) ---
        statuses = ["pending", "paid", "shipped", "delivered", "cancelled"]
        orders = []
        for _ in range(num_orders):
            order_date = fake.date_between(start_date="-365d", end_date="today")
            orders.append((random.choice(customer_ids), order_date, random.choice(statuses)))

        execute_values(
            cur,
            """
            INSERT INTO orders (customer_id, order_date, order_status)
            VALUES %s;
            """,
            orders,
        )

        cur.execute("SELECT order_id, order_date FROM orders ORDER BY order_id;")
        order_rows = cur.fetchall()

        # --- 5) Order items ---
        order_items = []
        for (order_id, _order_date) in order_rows:
            items_count = random.randint(1, max_items_per_order)

            chosen_products = random.sample(product_ids, k=min(items_count, (len(product_ids))))

            for pid in chosen_products:
                qty = random.randint(1, 10)
                base_price = product_price_map[pid]
                price_at_purchase = round(base_price * random.uniform(0.85, 1.15), 2)
                order_items.append((order_id, pid, qty, price_at_purchase))

        execute_values(
            cur,
            """
            INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
            VALUES %s;
            """,
            order_items,
        )

        # --- 6) Shipments (random subset; valid dates) ---
        shipments = []
        for (order_id, order_date) in order_rows:
            if random.random() <= shipment_probability:
                shipped_date = order_date + timedelta(days=random.randint(0, 7))
                delivery_date = shipped_date + timedelta(days=random.randint(1, 10))
                shipping_cost = round(random.uniform(20, 250), 2)
                shipments.append((order_id, shipped_date, delivery_date, shipping_cost))

        execute_values(
            cur,
            """
            INSERT INTO shipments (order_id, shipped_date, delivery_date, shipping_cost)
            VALUES %s;
            """,
            shipments,
        )

        conn.commit()

        print("Seed complete!")
        print(f"Suppliers: {num_suppliers}")
        print(f"Products: {num_products}")
        print(f"Customers: {num_customers}")
        print(f"Orders: {num_orders}")
        print(f"Order items inserted: {len(order_items)}")
        print(f"Shipments inserted: {len(shipments)}")

    except Exception as e:
        conn.rollback()
        print("Seeding failed:", e)

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    seed_database()
