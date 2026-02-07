import pandas as pd
import psycopg2
from psycopg2 import sql
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


# Load cleaned data
df = pd.read_csv('dstakehome_merchants_clean.csv')
print("Loaded cleaned data:", len(df), "rows")

# Convert first_charge_date to proper date format
df['first_charge_date'] = pd.to_datetime(df['first_charge_date']).dt.date

# Connect to PostgreSQL
print("\nConnecting to PostgreSQL...")
conn = psycopg2.connect(
    host="localhost",
    database="stripe_db",
    user="postgres",
    password=os.getenv('DB_PASSWORD')  # ✅ Use environment variable
)
cur = conn.cursor()

# Insert data
print("Inserting data into PostgreSQL...")
inserted = 0

for index, row in df.iterrows():
    try:
        cur.execute(
            """
            INSERT INTO merchants (merchant, industry, first_charge_date, country, business_size)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (row['merchant'], row['industry'], row['first_charge_date'], row['country'], row['business_size'])
        )
        inserted += 1
        
        if inserted % 1000 == 0:
            print(f"Inserted {inserted} rows...")
            
    except Exception as e:
        print(f"Error on row {index}: {e}")
        conn.rollback()
        break

conn.commit()
cur.close()
conn.close()

print(f"Total rows inserted: {inserted}")
print("Data load complete!")
