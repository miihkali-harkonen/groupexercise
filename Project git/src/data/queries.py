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
                        WHERE stock_quantity < 10
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
if __name__ == "__main__":
    count_low_stock_products()