import psycopg2
from psycopg2 import DatabaseError
from .config import config


def connect():
    """Connect to the PostgreSQL database and return the connection."""
    try:
        return psycopg2.connect(**config())
    except (Exception, DatabaseError) as error:
        print("DB connection error:", error)
        return None

def count_low_stock_products():
    conn = connect()
    if conn == None:
        return
    try:
        cur = conn.cursor()
        cur.execute("""SELECT COUNT(*) AS low_stock_products
                        FROM products
                        WHERE stock_quantity < 10;
                    """)
        low_stock_count = cur.fetchone()[0]
        print(f"THe count of products with stock quantity less than 10 is {low_stock_count}")
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()

def avg_order_value():
    conn = connect()
    if conn == None:
        return
    try:
        cur = conn.cursor()
        cur.execute("""SELECT AVG(total_order) AS avg_ord_val
                        FROM (SELECT order_id, SUM(quantity * price_at_purchase) AS total_order
                            FROM order_items
                            GROUP BY order_id)
                            AS sub;
                    """)
        average_order = cur.fetchone()[0]
        print(f"The average order value is {average_order}")
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()

def peak_order_days_over_time():
    conn = connect()
    if conn == None:
        return
    try:
        cur = conn.cursor()
        cur.execute("""SELECT order_date, COUNT(*) AS daily_order
                    FROM orders
                    WHERE order_status <> 'cancelled'
                    GROUP BY order_date
                    ORDER BY daily_order DESC
                    LIMIT 10;
                    """)
        top_orders = cur.fetchall()
        print("The top 10 peak days are as follow:")
        for order in top_orders:
            print(f"{order[1]} orders have been made on {order[0]}")
        
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()

        
if __name__ == "__main__":
    count_low_stock_products()
    avg_order_value()
    peak_order_days_over_time()