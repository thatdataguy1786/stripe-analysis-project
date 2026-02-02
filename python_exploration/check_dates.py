import pandas as pd

df = pd.read_csv('dstakehome_merchants_clean.csv')

print("INVESTIGATING DATE FIELD")
print("-" * 60)
print("Total rows:", len(df))
print()

# Check date field as-is
print("Sample raw date values:")
print(df['first_charge_date'].head(10).tolist())
print()

# Try to convert with errors flagged
df['date_parsed'] = pd.to_datetime(df['first_charge_date'], errors='coerce')

# Count valid vs invalid
valid_dates = df['date_parsed'].notna().sum()
invalid_dates = df['date_parsed'].isna().sum()

print("Date validation results:")
print("Valid dates:", valid_dates)
print("Invalid dates:", invalid_dates)
print()

# Show rows with invalid dates
if invalid_dates > 0:
    print("Rows with INVALID dates:")
    invalid_rows = df[df['date_parsed'].isna()]
    print(invalid_rows[['merchant', 'industry', 'first_charge_date', 'country']].head(20))
    print()
    
    # Check what the invalid values look like
    print("Unique invalid date values:")
    print(invalid_rows['first_charge_date'].unique())
    print()

# Show valid date range
if valid_dates > 0:
    print("Valid date range:")
    print("Earliest:", df['date_parsed'].min())
    print("Latest:", df['date_parsed'].max())
