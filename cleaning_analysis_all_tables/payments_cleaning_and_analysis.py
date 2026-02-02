import pandas as pd

# STEP 1: LOAD DATA
print("STEP 1: LOADING PAYMENTS DATA")
print("-" * 60)
df = pd.read_excel('dstakehome_payments.xlsx')
print("Initial rows:", len(df))
print("Columns:", df.columns.tolist())
print()

# STEP 2: DATA TYPES
print("STEP 2: DATA TYPES")
print("-" * 60)
print(df.dtypes)
print()

# STEP 3: NULL CHECK
print("STEP 3: NULL VALUES")
print("-" * 60)
nulls = df.isnull().sum()
if nulls.sum() == 0:
    print("No null values")
else:
    print(nulls[nulls > 0])
print()

# STEP 4: MERCHANT ID VALIDATION
print("STEP 4: MERCHANT ID VALIDATION")
print("-" * 60)
df['merchant_str'] = df['merchant'].astype(str)
df['is_valid_merchant'] = df['merchant_str'].str.match(r'^[a-f0-9]{8}$')

valid = df['is_valid_merchant'].sum()
invalid = (~df['is_valid_merchant']).sum()

print("Valid merchant IDs:", valid)
print("Invalid merchant IDs:", invalid)

if invalid > 0:
    print("Sample invalid merchant IDs:")
    print(df[~df['is_valid_merchant']]['merchant_str'].unique()[:10])
print()

# STEP 5: DATE VALIDATION
print("STEP 5: DATE VALIDATION")
print("-" * 60)
df['date_parsed'] = pd.to_datetime(df['date'], errors='coerce')

valid_dates = df['date_parsed'].notna().sum()
invalid_dates = df['date_parsed'].isna().sum()

print("Valid dates:", valid_dates)
print("Invalid dates:", invalid_dates)

if valid_dates > 0:
    print("Date range:", df['date_parsed'].min(), "to", df['date_parsed'].max())
print()

# STEP 6: VOLUME VALIDATION
print("STEP 6: VOLUME FIELD VALIDATION")
print("-" * 60)
volume_cols = ['subscription_volume', 'checkout_volume', 'payment_link_volume', 'total_volume']

for col in volume_cols:
    print(f"{col}:")
    print(f"  Min: {df[col].min()}")
    print(f"  Max: {df[col].max()}")
    print(f"  Negative values: {(df[col] < 0).sum()}")
print()

# STEP 7: CLEAN DATA
print("STEP 7: CLEANING DATA")
print("-" * 60)

# Keep only valid merchant IDs
df_clean = df[df['is_valid_merchant']].copy()
print("After merchant ID filter:", len(df_clean))

# Keep only valid dates
df_clean = df_clean[df_clean['date_parsed'].notna()].copy()
print("After date filter:", len(df_clean))

# Drop helper columns
df_clean = df_clean.drop(['merchant_str', 'is_valid_merchant', 'date_parsed'], axis=1)

print("Total rows removed:", len(df) - len(df_clean))
print()

# STEP 8: FINAL SUMMARY
print("STEP 8: FINAL CLEANED DATA")
print("-" * 60)
print("Original rows:", len(df))
print("Final rows:", len(df_clean))
print()

print("Sample cleaned data:")
print(df_clean.head())
print()

# STEP 9: SAVE
print("STEP 9: SAVING CLEANED DATA")
print("-" * 60)
df_clean.to_csv('dstakehome_payments_clean.csv', index=False)
print("Saved to: dstakehome_payments_clean.csv")
print()

print("CLEANING COMPLETE")
print("=" * 60)
