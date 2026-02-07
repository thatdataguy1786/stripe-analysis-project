
/* MERCHANT TABLE */

Select * from merchants limit 5


/* Checking data quality */

Select COUNT(*) as total_rows,
 COUNT(DISTINCT merchant) as unique_merchants,
 MIN(first_charge_date) as earliest_date,
 MAX(first_charge_date) AS latest_date
 FROM merchants

/* Business Size Distribution */

Select merchants.business_size,
       COUNT(*) as count
FROM merchants
GROUP BY merchants.business_size
ORDER BY count DESC


/* Merchants in each country */
Select merchants.country,
       COUNT(*) as count
FROM merchants
GROUP BY merchants.country
ORDER BY count DESC
LIMIT 10


/* Merchants by industry */
Select merchants.industry,
       COUNT(*) as count
FROM merchants
GROUP BY merchants.industry
ORDER BY count DESC
--LIMIT 10

/* Dsitrbution by country & business size */
Select merchants.country,
       merchants.business_size,
       COUNT(*) as count
FROM merchants
GROUP BY merchants.country,merchants.business_size
ORDER BY count DESC


/* PAYMENTS */

/* counting rows in both the tables */
SELECT 
    (SELECT COUNT(*) FROM merchants) as merchants_count,
    (SELECT COUNT(*) FROM payments) as payments_count;


 /* Check sample join */

  SELECT 
    m.merchant,
    m.industry,
    m.country,
    p.date,
    p.total_volume
FROM merchants m
JOIN payments p ON m.merchant = p.merchant
LIMIT 10;  

/* Checking for ID randomly  merchant = 5d03e714 */

With base as (Select *, date_trunc('MONTH', date) as trx_month from payments
where merchant = '5d03e714')

Select trx_month, SUM(total_volume) as monthly_totals 
from base
GROUP BY trx_month
ORDER BY trx_month

/* DATE RANGE IN PAYMENTS */
SELECT 
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    COUNT(DISTINCT date) as unique_days,
    COUNT(DISTINCT merchant) as unique_merchants
FROM payments;

/*Rough Work*/
Select 
      merchants.merchant
    , merchants.country
    , COUNT(CASE WHEN payments.payment_link_volume > 0 THEN 1 ELSE 0 END) as payment_trx
    , COUNT(CASE WHEN payments.subscription_volume > 0 THEN 1 ELSE 0 END) as subscription_trx
    , COUNT(CASE WHEN payments.checkout_volume > 0 THEN 1 ELSE 0 END) as checkout_trx
    , COUNT(CASE WHEN payments.total_volume > 0 THEN 1 ELSE 0 END) as total_trx
 FROM merchants JOIN payments ON payments.merchant = merchants.merchant
 WHERE merchants.industry = 'Software'
 GROUP BY 1,2


Select merchant, COUNT(*) AS total_trx from payments 
GROUP BY merchant
ORDER BY total_trx DESC

Select * from payments 
WHERE merchant = '2d0a70fe'

