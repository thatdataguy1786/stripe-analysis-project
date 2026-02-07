import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch

# Load cleaned data
print("Loading cleaned payments data...")
payments_df = pd.read_csv('dstakehome_payments_clean.csv')
print(f"Initial payment rows: {len(payments_df):,}")

# Load merchants to get valid merchant list
merchants_df = pd.read_csv('dstakehome_merchants_clean.csv')
valid_merchants = set(merchants_df['merchant'].unique())
print(f"Valid merchants: {len(valid_merchants):,}")

# Filter payments to only include valid merchants
payments_df = payments_df[payments_df['merchant'].isin(valid_merchants)].copy()
print(f"Payment rows after filtering: {len(payments_df):,}")
print(f"Rows excluded: {len(pd.read_csv('dstakehome_payments_clean.csv')) - len(payments_df):,}")

# Convert date format
payments_df['date'] = pd.to_datetime(payments_df['date']).dt.date

# Connect to PostgreSQL
print("\nConnecting to PostgreSQL...")
conn = psycopg2.connect(
    host="localhost",
    database="stripe_db",
    user="postgres",
    password="Postgres17!" 
)
cur = conn.cursor()

# Prepare data for bulk insert
print("Preparing data for bulk insert...")
data = [
    (
        row['date'],
        row['merchant'],
        row['subscription_volume'],
        row['checkout_volume'],
        row['payment_link_volume'],
        row['total_volume']
    )
    for _, row in payments_df.iterrows()
]

# Bulk insert
print("Inserting data... (this will take 2-3 minutes)")
execute_batch(
    cur,
    """
    INSERT INTO payments (date, merchant, subscription_volume, checkout_volume, payment_link_volume, total_volume)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (date, merchant) DO NOTHING
    """,
    data,
    page_size=1000
)

conn.commit()
print(f"\nInsert complete!")

# Verify
cur.execute("SELECT COUNT(*) FROM payments")
count = cur.fetchone()[0]
print(f"Total rows in payments table: {count:,}")

cur.close()
conn.close()
print("Done!")
