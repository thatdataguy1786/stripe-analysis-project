
/* Getting the difference between each transaction per merchant and then eventually creating a view for non-subscribed merchants */

CREATE VIEW recurring_merchants AS
WITH merchant_dates AS
 (SELECT merchant,
       date,
       LAG(date) OVER (PARTITION BY merchant ORDER BY date) as prev_date
FROM payments
WHERE subscription_volume = 0)

, days_between_transactions AS
(SELECT merchant,
        date - prev_date as days_between_transactions
FROM merchant_dates
WHERE prev_date IS NOT NULL)

, avg_days_between_transactions AS 
(SELECT DISTINCT merchant,
        ROUND(AVG(days_between_transactions),2) as avg_days_between_transactions
FROM days_between_transactions        
GROUP BY 1
)

, total_transactions_per_merchant AS 
(SELECT DISTINCT merchant,
        COUNT(*) as total_transactions_per_merchant
FROM payments
WHERE subscription_volume = 0
GROUP BY 1

)

, final as (SELECT m.merchant,
       m.industry,
       m.country,
       m.business_size,
       a.avg_days_between_transactions, 
       b.total_transactions_per_merchant,
       ROUND(SUM(p.total_volume)/100.0,2) AS total_volume_dollars,
       ROUND(SUM(p.checkout_volume) / 100.0,2) as total_checkout_dollars,
       ROUND(SUM(p.payment_link_volume) / 100.0,2) as total_payment_link_dollars,
       ROUND(SUM(p.checkout_volume) * 100.0 / NULLIF(SUM(p.total_volume), 0), 2) as checkout_percentage,
       ROUND(SUM(p.payment_link_volume) * 100.0 / NULLIF(SUM(p.total_volume), 0), 2) as payment_link_percentage,
       COUNT(DISTINCT DATE_TRUNC('month', p.date)) as months_active,
       ROUND((b.total_transactions_per_merchant)/COUNT(DISTINCT DATE_TRUNC('month', p.date))) as avg_trx_for_a_merchant_in_a_month,
       ROUND(SUM(p.total_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100, 2) as avg_monthly_volume_dollars,
       ROUND(SUM(p.checkout_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100.0, 2) as avg_monthly_checkout_dollars
FROM avg_days_between_transactions a       
JOIN merchants m 
ON a.merchant = m.merchant
JOIN total_transactions_per_merchant b 
ON m.merchant = b.merchant
JOIN payments p 
ON b.merchant = p.merchant
/*filtering out merchants having less than on average 10 transactions days between them */
WHERE avg_days_between_transactions <=10
/* Filtering out merchants with less than 10 transactions over all- Definitely not out target audience */
AND total_transactions_per_merchant > 10
GROUP BY 1,2,3,4,5,6
ORDER BY total_volume_dollars DESC
)

SELECT 
*
FROM final

DROP VIEW recurring_merchants


/* Creating a view for allready subscribed/on-subscription merchants */

CREATE VIEW recurring_merchants_subscribed AS
WITH merchant_dates AS
 (SELECT merchant,
       date,
       LAG(date) OVER (PARTITION BY merchant ORDER BY date) as prev_date
FROM payments
WHERE subscription_volume > 0)

, days_between_transactions AS
(SELECT merchant,
        date - prev_date as days_between_transactions
FROM merchant_dates
WHERE prev_date IS NOT NULL)

, avg_days_between_transactions AS 
(SELECT DISTINCT merchant,
        ROUND(AVG(days_between_transactions),2) as avg_days_between_transactions
FROM days_between_transactions        
GROUP BY 1
)

, total_transactions_per_merchant AS 
(SELECT DISTINCT merchant,
        COUNT(*) as total_transactions_per_merchant
FROM payments
WHERE subscription_volume > 0
GROUP BY 1

)

, final as (SELECT m.merchant,
       m.industry,
       m.country,
       m.business_size,
       a.avg_days_between_transactions, 
       b.total_transactions_per_merchant,
       ROUND(SUM(p.total_volume)/100.0,2) AS total_volume_dollars,
       ROUND(SUM(p.checkout_volume) / 100.0,2) as total_checkout_dollars,
       ROUND(SUM(p.payment_link_volume) / 100.0,2) as total_payment_link_dollars,
       ROUND(SUM(p.subscription_volume) / 100.0,2) as total_subscription_dollars,
       ROUND(SUM(p.subscription_volume) * 100.0 / NULLIF(SUM(p.total_volume), 0), 2) as subscription_percentage,
       ROUND(SUM(p.checkout_volume) * 100.0 / NULLIF(SUM(p.total_volume), 0), 2) as checkout_percentage,
       ROUND(SUM(p.payment_link_volume) * 100.0 / NULLIF(SUM(p.total_volume), 0), 2) as payment_link_percentage,
       COUNT(DISTINCT DATE_TRUNC('month', p.date)) as months_active,
       ROUND((b.total_transactions_per_merchant)/COUNT(DISTINCT DATE_TRUNC('month', p.date))) as avg_no_of_trx_for_a_merchant_per_month,
       ROUND(SUM(p.subscription_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100.0, 2) as avg_monthly_subscription_dollars,
       ROUND(SUM(p.total_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100, 2) as avg_monthly_volume_dollars,
       ROUND(SUM(p.checkout_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100.0, 2) as avg_monthly_checkout_dollars
FROM avg_days_between_transactions a
JOIN merchants m 
ON a.merchant = m.merchant
JOIN total_transactions_per_merchant b 
ON m.merchant = b.merchant
JOIN payments p 
ON b.merchant = p.merchant
WHERE avg_days_between_transactions <=10
AND total_transactions_per_merchant > 10
GROUP BY 1,2,3,4,5,6
ORDER BY total_volume_dollars DESC
)
Select * from final





DROP VIEW recurring_merchants_subscribed