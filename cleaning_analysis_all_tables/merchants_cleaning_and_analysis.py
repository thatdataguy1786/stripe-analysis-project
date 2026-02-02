import pandas as pd

# STEP 1: LOAD DATA
print("STEP 1: LOADING DATA")
print("-" * 60)
df = pd.read_csv('dstakehome_merchants.csv')
print("Initial rows:", len(df))
print("Columns:", df.columns.tolist())
print()

# STEP 2: DATA TYPES AND STRUCTURE
print("STEP 2: DATA TYPES AND STRUCTURE")
print("-" * 60)
print(df.dtypes)
print()

# STEP 3: NULL VALUES CHECK
print("STEP 3: NULL VALUES CHECK")
print("-" * 60)
null_counts = df.isnull().sum()
if null_counts.sum() == 0:
    print("No null values found")
else:
    print(null_counts[null_counts > 0])
print()

# STEP 4: TEXT FIELD LENGTHS (for table design)
print("STEP 4: TEXT FIELD MAX LENGTHS")
print("-" * 60)
print("merchant:", df['merchant'].astype(str).str.len().max())
print("industry:", df['industry'].str.len().max())
print("country:", df['country'].str.len().max())
print("business_size:", df['business_size'].str.len().max())
print()

# STEP 5: MERCHANT ID PATTERN ANALYSIS
print("STEP 5: MERCHANT ID PATTERN ANALYSIS")
print("-" * 60)
df['merchant_str'] = df['merchant'].astype(str)

print("Merchant ID length distribution:")
print(df['merchant_str'].str.len().value_counts().sort_index())
print()

df['is_alphanumeric'] = df['merchant_str'].str.match(r'^[a-f0-9]{8}$')
df['is_numeric_only'] = df['merchant_str'].str.match(r'^[0-9]+$')
df['is_scientific'] = df['merchant_str'].str.contains('E', case=True)

print("Pattern breakdown:")
print("Valid alphanumeric (8-char hex):", df['is_alphanumeric'].sum())
print("Numeric only:", df['is_numeric_only'].sum())
print("Scientific notation:", df['is_scientific'].sum())
print()

# STEP 6: DUPLICATE CHECK (before cleaning)
print("STEP 6: DUPLICATE CHECK (BEFORE CLEANING)")
print("-" * 60)
initial_dups = df['merchant'].duplicated().sum()
print("Duplicates found:", initial_dups)
print()

# STEP 7: DATA CLEANING - MERCHANT IDs
print("STEP 7: DATA CLEANING - MERCHANT IDs")
print("-" * 60)
print("Keeping only valid alphanumeric merchant IDs...")

df_clean = df[df['is_alphanumeric']].copy()
df_clean = df_clean.drop(['merchant_str', 'is_alphanumeric', 'is_numeric_only', 'is_scientific'], axis=1)

print("Rows after merchant ID cleaning:", len(df_clean))
print()

# STEP 8: DATA CLEANING - DATES
print("STEP 8: DATA CLEANING - DATES")
print("-" * 60)
print("Validating date field...")

df_clean['date_parsed'] = pd.to_datetime(df_clean['first_charge_date'], errors='coerce')

valid_dates = df_clean['date_parsed'].notna().sum()
invalid_dates = df_clean['date_parsed'].isna().sum()

print("Valid dates:", valid_dates)
print("Invalid dates:", invalid_dates)

if invalid_dates > 0:
    print("Removing rows with invalid dates...")
    df_clean = df_clean[df_clean['date_parsed'].notna()].copy()

df_clean = df_clean.drop('date_parsed', axis=1)
print("Rows after date cleaning:", len(df_clean))
print()

# STEP 9: VERIFY CLEANING
print("STEP 9: VERIFY CLEANING")
print("-" * 60)
final_dups = df_clean['merchant'].duplicated().sum()
print("Duplicates after cleaning:", final_dups)
print()

# STEP 10: FINAL DATA SUMMARY
print("STEP 10: FINAL CLEANED DATA SUMMARY")
print("-" * 60)
print("Original rows:", len(df))
print("Final rows:", len(df_clean))
print("Total removed:", len(df) - len(df_clean))
print()

print("Final column max lengths:")
print("merchant:", df_clean['merchant'].astype(str).str.len().max())
print("industry:", df_clean['industry'].str.len().max())
print("country:", df_clean['country'].str.len().max())
print("business_size:", df_clean['business_size'].str.len().max())
print()

print("Sample of cleaned data:")
print(df_clean.head())
print()

# STEP 11: SAVE CLEANED DATA
print("STEP 11: SAVING CLEANED DATA")
print("-" * 60)
df_clean.to_csv('dstakehome_merchants_clean.csv', index=False)
print("Cleaned data saved to: dstakehome_merchants_clean.csv")
print()

print("ANALYSIS AND CLEANING COMPLETE")
print("=" * 60)
