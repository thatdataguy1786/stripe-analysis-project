

/*Query 1: WHO ARE THE MOST SUCCESSFUL SUBSCRIPTION MERCHANTS?
Purpose: Learn from winners - what do high-value subscription merchants look like?
Business Use: These are the profiles to replicate when targeting non-subscription merchants. */

SELECT 
    industry,
    country,
    COUNT(DISTINCT merchant) as successful_merchants,
    ROUND(AVG(avg_monthly_subscription_dollars), 2) as avg_monthly_sub_revenue,
    ROUND(AVG(subscription_percentage), 2) as avg_sub_percentage_of_revenue,
    ROUND(AVG(months_active), 2) as avg_tenure,
    ROUND(AVG(avg_no_of_trx_for_a_merchant_per_month::NUMERIC), 2) as avg_monthly_transactions
FROM recurring_merchants_subscribed
WHERE avg_monthly_subscription_dollars >= 5000  -- Filter: Focus on meaningful subscription revenue
  AND subscription_percentage >= 30  -- Filter: Subscriptions are significant part of their business
  AND months_active >= 6  -- Filter: Established users, not just testing
GROUP BY industry, country
HAVING COUNT(DISTINCT merchant) >= 5  -- Filter: Need enough sample size
ORDER BY avg_monthly_sub_revenue DESC
LIMIT 15;


/*Query 2: CHECKOUT → SUBSCRIPTION CONVERSION PATH
Purpose: Which industries/countries successfully use BOTH Checkout AND Subscriptions?
Business Use: Target non-subscription merchants in these segments - they have an easier migration path! */

SELECT 
    industry,
    country,
    COUNT(DISTINCT merchant) as hybrid_merchants,
    ROUND(AVG(subscription_percentage), 2) as avg_sub_pct,
    ROUND(AVG(checkout_percentage), 2) as avg_checkout_pct,
    ROUND(AVG(avg_monthly_subscription_dollars), 2) as avg_monthly_sub_revenue,
    ROUND(AVG(avg_monthly_checkout_dollars), 2) as avg_monthly_checkout_revenue
FROM recurring_merchants_subscribed
WHERE avg_monthly_checkout_dollars >= 500  -- Lowered from 1000
  AND avg_monthly_subscription_dollars >= 500  -- Lowered from 1000
  AND checkout_percentage >= 10  -- Lowered from 20 (any meaningful checkout usage)
  AND subscription_percentage >= 10  -- Lowered from 20 (any meaningful subscription usage)
  AND months_active >= 6
GROUP BY industry, country
HAVING COUNT(DISTINCT merchant) >= 3
ORDER BY hybrid_merchants DESC, avg_monthly_sub_revenue DESC
LIMIT 15;


/*
Query 3: SUBSCRIPTION RELIANCE BY SEGMENT
Purpose: Which segments have HIGHEST subscription dependency?
Business Use: High reliance = subscription is ESSENTIAL for that business model = strong selling point
*/

SELECT 
    industry,
    business_size,
    COUNT(DISTINCT merchant) as merchants,
    ROUND(AVG(subscription_percentage), 2) as avg_subscription_reliance,
    ROUND(AVG(avg_monthly_subscription_dollars), 2) as avg_monthly_sub_revenue,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_total_monthly_revenue
FROM recurring_merchants_subscribed
WHERE subscription_percentage >= 50  -- Filter: Subscription-dominant businesses
  AND avg_monthly_subscription_dollars >= 3000  -- Filter: Meaningful revenue
  AND months_active >= 6
GROUP BY industry, business_size
HAVING COUNT(DISTINCT merchant) >= 5
ORDER BY avg_subscription_reliance DESC
LIMIT 15;

/*
Query 4: EARLY VS MATURE SUBSCRIPTION ADOPTERS
Purpose: Do newer merchants adopt subscriptions faster? Or is it mature merchants?
Business Use: Tells you WHEN in merchant lifecycle to target them
*/

WITH merchant_data AS (
    SELECT 
        merchant,
        months_active,
        avg_monthly_subscription_dollars,
        subscription_percentage,
        avg_monthly_volume_dollars,
        avg_no_of_trx_for_a_merchant_per_month,
        CASE 
            WHEN months_active <= 6 THEN 'New (≤6 months)'
            WHEN months_active <= 12 THEN 'Growing (7-12 months)'
            ELSE 'Mature (12+ months)'
        END as merchant_maturity
    FROM recurring_merchants_subscribed
    WHERE avg_monthly_subscription_dollars >= 2000
)
SELECT 
    merchant_maturity,
    COUNT(DISTINCT merchant) as merchants,
    ROUND(AVG(avg_monthly_subscription_dollars), 2) as avg_monthly_sub_revenue,
    ROUND(AVG(subscription_percentage), 2) as avg_sub_percentage,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_total_revenue,
    ROUND(AVG(avg_no_of_trx_for_a_merchant_per_month::NUMERIC), 2) as avg_monthly_trx
FROM merchant_data
GROUP BY merchant_maturity
ORDER BY 
    CASE merchant_maturity
        WHEN 'New (≤6 months)' THEN 1
        WHEN 'Growing (7-12 months)' THEN 2
        ELSE 3
    END;


/*Query 5:TRANSACTION FREQUENCY × SUBSCRIPTION SUCCESS
Purpose: Do more frequent transactors succeed more with subscriptions?
Business Use: Validates your "≤10 days between transactions" targeting criteria */

WITH filtered_merchants AS (
    SELECT *
    FROM recurring_merchants_subscribed
    WHERE avg_monthly_subscription_dollars >= 2000
      AND months_active >= 6
),
categorized_merchants AS (
    SELECT 
        merchant,
        avg_monthly_subscription_dollars,
        subscription_percentage,
        avg_no_of_trx_for_a_merchant_per_month::NUMERIC,
        CASE 
            WHEN avg_days_between_transactions <= 3 THEN 'Very Frequent (≤3 days)'
            WHEN avg_days_between_transactions <= 7 THEN 'Frequent (4-7 days)'
            ELSE 'Moderate (8-10 days)'
        END as transaction_frequency
    FROM filtered_merchants
)
SELECT 
    transaction_frequency,
    COUNT(DISTINCT merchant) as merchants,
    ROUND(AVG(avg_monthly_subscription_dollars), 2) as avg_monthly_sub_revenue,
    ROUND(AVG(subscription_percentage), 2) as avg_sub_percentage,
    ROUND(AVG(avg_no_of_trx_for_a_merchant_per_month::NUMERIC), 2) as avg_monthly_trx
FROM categorized_merchants
GROUP BY transaction_frequency
ORDER BY 
    CASE transaction_frequency
        WHEN 'Very Frequent (≤3 days)' THEN 1
        WHEN 'Frequent (4-7 days)' THEN 2
        ELSE 3
    END;


/* Merchants from Industries that currently use subscriptions */
SELECT m.industry,
       COUNT(DISTINCT m.merchant) AS total_merchants,
       COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) AS merchants_with_subscription,
       ROUND((COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) * 100.0)/COUNT(DISTINCT p.merchant),2)  AS adoption_rate 
FROM merchants m JOIN payments p ON m.merchant = p.merchant     
GROUP BY m.industry
ORDER BY adoption_rate DESC   


SELECT m.country,
       COUNT(DISTINCT m.merchant) AS total_merchants,
       COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) AS merchants_with_subscription,
       ROUND((COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) * 100.0)/COUNT(DISTINCT p.merchant),2)  AS adoption_rate 
FROM merchants m JOIN payments p ON m.merchant = p.merchant     
GROUP BY m.country
ORDER BY total_merchants DESC, adoption_rate DESC  


SELECT m.business_size,
       COUNT(DISTINCT m.merchant) AS total_merchants,
       COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) AS merchants_with_subscription,
       ROUND((COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) * 100.0)/COUNT(DISTINCT p.merchant),2)  AS adoption_rate 
FROM merchants m JOIN payments p ON m.merchant = p.merchant     
GROUP BY m.business_size
ORDER BY adoption_rate DESC  


SELECT m.industry,
       m.country,
       COUNT(DISTINCT m.merchant) AS total_merchants,
       COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) AS merchants_with_subscription,
       ROUND((COUNT(DISTINCT CASE WHEN p.subscription_volume > 0 THEN  p.merchant END) * 100.0)/COUNT(DISTINCT p.merchant),2)  AS adoption_rate 
FROM merchants m JOIN payments p ON m.merchant = p.merchant     
GROUP BY m.industry, m.country
ORDER BY total_merchants DESC, adoption_rate DESC      