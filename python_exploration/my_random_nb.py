import pandas as pd

# STEP 1: LOAD DATA
print("STEP 1: LOADING DATA")
print("-" * 60)
df = pd.read_csv('dstakehome_merchants.csv')
print("Initial rows:", len(df))
print("Columns:", df.columns.tolist())
print()

intial_dups = df['merchant'].duplicated(keep = False).sum()
print(intial_dups)

null_counts = df.isnull().sum()
print(null_counts)

null_merchants = df['merchant'].isnull().sum()
null_merchants = df['merchant'].isna().sum()
null_industry = df['industry'].isnull().sum()
null_country = df['country'].isna().sum()
null_bs = df['business_size'].isna().sum()

print("null mechants count is:", null_merchants)
print(null_merchants)
print(f"null_industry count is:{null_industry}")
print(null_country)
print(null_bs)

#print(df[df['merchant'].duplicated(keep = False)])