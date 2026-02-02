import pandas as pd

# Load the payments data
df = pd.read_excel('dstakehome_payments.xlsx')

print("PAYMENTS DATA - INITIAL EXPLORATION")
print("-" * 60)
print("Rows:", len(df))
print("Columns:", df.columns.tolist())
print()

print("Data types:")
print(df.dtypes)
print()

print("First 5 rows:")
print(df.head())
print()

print("Null values:")
print(df.isnull().sum())
