import pandas as pd

df = pd.read_csv('dstakehome_payments_clean.csv')

df['calculated_total'] = df['subscription_volume'] + df['checkout_volume'] + df['payment_link_volume']
df['mismatch'] = df['calculated_total'] != df['total_volume']

print("Rows with total_volume mismatch:", df['mismatch'].sum())
print("Percentage:", (df['mismatch'].sum() / len(df) * 100), "%")
