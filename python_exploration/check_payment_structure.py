import pandas as pd

df = pd.read_csv('dstakehome_payments_clean.csv')

# Check for duplicates on date + merchant
dups = df.duplicated(subset=['date', 'merchant']).sum()
print("Duplicate (date, merchant) combinations:", dups)

# Check one merchant on one day
sample = df[(df['merchant'] == '5d03e714') & (df['date'] == '2041-05-01T00:00:00Z')]
print("\nSample: merchant 5d03e714 on 2041-05-01:")
print(sample)

# Check if any row has multiple products with non-zero values
df['products_used'] = (
    (df['subscription_volume'] > 0).astype(int) +
    (df['checkout_volume'] > 0).astype(int) +
    (df['payment_link_volume'] > 0).astype(int)
)

print("\nNumber of products used per row:")
print(df['products_used'].value_counts().sort_index())
