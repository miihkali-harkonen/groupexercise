from .queries import connect

if __name__ == "__main__":
    conn = connect()
    if conn:
        print("Connected to database!")
        conn.close()
    else:
        print("Connection failed")