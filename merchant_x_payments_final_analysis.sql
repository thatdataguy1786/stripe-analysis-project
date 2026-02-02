/* Merchants from Industries that currently use subscriptions */
SELECT m.industry,
       COUNT(DISTINCT p.merchant) AS total_merchants,
       COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) AS merchants_with_subscription,
       ROUND((COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) * 100.0)/COUNT(DISTINCT p.merchant),2)  AS adoption_rate 
FROM merchants m JOIN payments p ON m.merchant = p.merchant     
GROUP BY m.industry
ORDER BY adoption_rate DESC   



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
       ROUND(SUM(p.total_volume)/100,2) AS total_volume_dollars,
       COUNT(DISTINCT DATE_TRUNC('month', p.date)) as months_active,
       ROUND(SUM(p.total_volume) / COUNT(DISTINCT DATE_TRUNC('month', p.date)) / 100, 2) as avg_monthly_volume_dollars
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






SELECT 
    CASE 
        WHEN avg_monthly_volume_dollars >= 30000 THEN 'Whale'
        WHEN avg_monthly_volume_dollars >= 8750 THEN 'Dolphin'
        ELSE 'Guppy'
    END as merchant_tier,
    COUNT(*) as merchant_count,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume
FROM recurring_merchants
GROUP BY 1
ORDER BY avg_monthly_volume DESC;





/* Target Scoring */
With base as (SELECT 
    merchant,
    industry,
    country,
    business_size,
    avg_days_between_transactions,
    total_transactions_per_merchant,
    months_active,
    avg_monthly_volume_dollars,
    avg_monthly_checkout_dollars,
    checkout_percentage,
    
    -- Volume Tier
    CASE 
        WHEN avg_monthly_volume_dollars >= 30000 THEN 'Whale'
        WHEN avg_monthly_volume_dollars >= 8750 THEN 'Dolphin'
        ELSE 'Guppy'
    END as volume_tier,
    
    -- Scoring Components
    CASE 
        WHEN avg_monthly_volume_dollars >= 30000 THEN 3
        WHEN avg_monthly_volume_dollars >= 8750 THEN 2
        ELSE 1 
    END as volume_score,
    
    CASE 
        WHEN avg_monthly_checkout_dollars >= 20000 THEN 3
        WHEN avg_monthly_checkout_dollars >= 6000 THEN 2
        ELSE 1 
    END as checkout_score,
    
    CASE 
        WHEN months_active >= 12 THEN 3
        WHEN months_active >= 6 THEN 2
        ELSE 1 
    END as engagement_score,
    
    CASE 
        WHEN avg_days_between_transactions <= 5 THEN 3
        WHEN avg_days_between_transactions <= 7 THEN 2
        ELSE 1 
    END as frequency_score,

        CASE 
        WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3
        WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2
        ELSE 1 
    END as per_month_frequency_score,
    
    -- Total Score (max 15)
    (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
     CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
     CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
     CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END+
     CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
    
FROM recurring_merchants
ORDER BY priority_score DESC, avg_monthly_volume_dollars DESC
)

Select 
    
       COUNT(DISTINCT CASE WHEN priority_score>=12 then merchant end) as perfect_targets,
       COUNT(DISTINCT CASE WHEN priority_score<=11 and priority_score >=9 then merchant end) as excellent_targets,
       COUNT(DISTINCT CASE WHEN priority_score<9 then merchant end) as good_targets
from base       
 






SELECT 
    industry,
    COUNT(DISTINCT merchant) as total_merchants,
    COUNT(DISTINCT CASE WHEN priority_score >= 12 THEN merchant END) as perfect_targets,
    COUNT(DISTINCT CASE WHEN priority_score >= 9 AND priority_score < 12 THEN merchant END) as excellent_targets,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
    ROUND(AVG(priority_score), 2) as avg_priority_score
FROM (
    SELECT 
        merchant,
        industry,
        avg_monthly_volume_dollars,
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
    FROM recurring_merchants
) scored
GROUP BY industry
ORDER BY perfect_targets DESC, total_merchants DESC;


SELECT 
    country,
    COUNT(DISTINCT merchant) as total_merchants,
    COUNT(DISTINCT CASE WHEN priority_score >= 12 THEN merchant END) as perfect_targets,
    COUNT(DISTINCT CASE WHEN priority_score >= 9 AND priority_score < 12 THEN merchant END) as excellent_targets,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
    ROUND(AVG(priority_score), 2) as avg_priority_score
FROM (
    SELECT 
        merchant,
        country,
        avg_monthly_volume_dollars,
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
    FROM recurring_merchants
) scored
GROUP BY country
ORDER BY perfect_targets DESC, total_merchants DESC;

SELECT 
    industry,
    country,
    business_size,
    COUNT(DISTINCT merchant) as total_merchants,
    COUNT(DISTINCT CASE WHEN priority_score >= 12 THEN merchant END) as perfect_targets,
    COUNT(DISTINCT CASE WHEN priority_score >= 9 AND priority_score < 12 THEN merchant END) as excellent_targets,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
    ROUND(AVG(priority_score), 2) as avg_priority_score
FROM (
    SELECT 
        merchant,
        industry,
        country,
        business_size,
        avg_monthly_volume_dollars,
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
    FROM recurring_merchants
) scored
GROUP BY industry, country, business_size
HAVING COUNT(DISTINCT merchant) >= 5
ORDER BY perfect_targets DESC, total_merchants DESC
LIMIT 30;


