
/* Target Scoring */

With base as (    SELECT 
        merchant,
        industry,
        country,
        business_size,
        avg_days_between_transactions,
        total_transactions_per_merchant,
        months_active,
        avg_monthly_volume_dollars,
        avg_monthly_checkout_dollars,
        avg_trx_for_a_merchant_in_a_month,
        checkout_percentage,
        
        -- Individual Score Components
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
        END as transaction_count_score,
        
        -- Total Priority Score (max 15)
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
        
    FROM recurring_merchants
ORDER BY priority_score DESC, avg_monthly_volume_dollars DESC
)

/*Getting Final Counts */
Select 
    
       COUNT(DISTINCT CASE WHEN priority_score>=12 then merchant end) as perfect_targets,
       COUNT(DISTINCT CASE WHEN priority_score<=11 and priority_score >=9 then merchant end) as excellent_targets,
       COUNT(DISTINCT CASE WHEN priority_score<9 then merchant end) as good_targets
from base       
 




/* Industry Split of  Perfect & Excellent Targets */

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


/* Country Split of  Perfect & Excellent Targets */
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


/* Industry x Country Split of  Perfect & Excellent Targets */
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


/*Score Distribution*/
/*Query B*/

WITH scored_merchants AS (
    SELECT 
        merchant,
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
    FROM recurring_merchants
)
SELECT 
    priority_score,
    COUNT(DISTINCT merchant) as merchant_count,
    ROUND(COUNT(DISTINCT merchant) * 100.0 / SUM(COUNT(DISTINCT merchant)) OVER (), 2) as percentage
FROM scored_merchants
GROUP BY priority_score
ORDER BY priority_score DESC;



/*Query C */

-- Top 10 segments by perfect targets
WITH scored_merchants AS (
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
)
SELECT 
    industry,
    country,
    business_size,
    COUNT(DISTINCT CASE WHEN priority_score >= 12 THEN merchant END) as perfect_targets,
    COUNT(DISTINCT merchant) as total_qualifying_merchants,
    ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
    ROUND(AVG(priority_score), 2) as avg_score
FROM scored_merchants
GROUP BY industry, country, business_size
HAVING COUNT(DISTINCT CASE WHEN priority_score >= 12 THEN merchant END) > 0
ORDER BY perfect_targets DESC, avg_monthly_volume DESC
LIMIT 10;


/*Query D*/

-- Compare your perfect targets to subscription winners
WITH non_sub_targets AS (
    SELECT 
        'Non-Subscribed Targets' as segment,
        industry,
        country,
        COUNT(DISTINCT merchant) as merchants,
        ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
        ROUND(AVG(avg_monthly_checkout_dollars), 2) as avg_monthly_checkout,
        ROUND(AVG(months_active), 2) as avg_tenure_months
    FROM recurring_merchants
    WHERE (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
           CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
           CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
           CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
           CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) >= 12
      AND industry IN ('Software', 'Business services')
      AND country = 'US'
    GROUP BY industry, country
),
sub_winners AS (
    SELECT 
        'Subscribed Winners' as segment,
        industry,
        country,
        COUNT(DISTINCT merchant) as merchants,
        ROUND(AVG(avg_monthly_volume_dollars), 2) as avg_monthly_volume,
        ROUND(AVG(avg_monthly_checkout_dollars), 2) as avg_monthly_checkout,
        ROUND(AVG(months_active), 2) as avg_tenure_months
    FROM recurring_merchants_subscribed
    WHERE avg_monthly_subscription_dollars >= 10000
      AND industry IN ('Software', 'Business services')
      AND country = 'US'
    GROUP BY industry, country
)
SELECT * FROM non_sub_targets
UNION ALL
SELECT * FROM sub_winners
ORDER BY industry, segment DESC;



/*Final Query for the List of merchants */

WITH scored_merchants AS (
    SELECT 
        merchant,
        industry,
        country,
        business_size,
        avg_days_between_transactions,
        total_transactions_per_merchant,
        months_active,
        avg_monthly_volume_dollars,
        avg_monthly_checkout_dollars,
        avg_trx_for_a_merchant_in_a_month,
        checkout_percentage,
        
        -- Individual Score Components
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
        END as transaction_count_score,
        
        -- Total Priority Score (max 15)
        (CASE WHEN avg_monthly_volume_dollars >= 30000 THEN 3 WHEN avg_monthly_volume_dollars >= 8750 THEN 2 ELSE 1 END +
         CASE WHEN avg_monthly_checkout_dollars >= 20000 THEN 3 WHEN avg_monthly_checkout_dollars >= 6000 THEN 2 ELSE 1 END +
         CASE WHEN months_active >= 12 THEN 3 WHEN months_active >= 6 THEN 2 ELSE 1 END +
         CASE WHEN avg_days_between_transactions <= 5 THEN 3 WHEN avg_days_between_transactions <= 7 THEN 2 ELSE 1 END +
         CASE WHEN avg_trx_for_a_merchant_in_a_month >= 25 THEN 3 WHEN avg_trx_for_a_merchant_in_a_month >= 15 THEN 2 ELSE 1 END) as priority_score
        
    FROM recurring_merchants
),

segmented_merchants AS (
    SELECT 
        *,
        -- Assign Target Tier
        CASE 
            WHEN priority_score >= 12 THEN 'Perfect Target'
            WHEN priority_score >= 9 THEN 'Excellent Target'
            ELSE 'Good Target'
        END as target_tier,
        
        -- Assign Campaign Priority (for phased rollout)
        CASE 
            WHEN priority_score >= 12 AND industry IN ('Software', 'Business services') AND country = 'US' AND business_size = 'small' 
                THEN 'Phase 1 - Immediate'
            WHEN priority_score >= 12 
                THEN 'Phase 2 - High Priority'
            WHEN priority_score >= 9 
                THEN 'Phase 3 - Secondary Wave'
            ELSE 'Phase 4 - Long Tail'
        END as campaign_priority,
        
        -- Create Segment Label
        CONCAT(industry, ' | ', country, ' | ', business_size) as segment
        
    FROM scored_merchants
)

SELECT 
    merchant as merchant_id,
    industry,
    country,
    business_size,
    segment,
    target_tier,
    campaign_priority,
    priority_score,
    
    -- Score Breakdown (for transparency)
    volume_score,
    checkout_score,
    engagement_score,
    frequency_score,
    transaction_count_score,
    
    -- Key Metrics
    ROUND(avg_monthly_volume_dollars, 2) as avg_monthly_volume_usd,
    ROUND(avg_monthly_checkout_dollars, 2) as avg_monthly_checkout_usd,
    ROUND(avg_days_between_transactions, 2) as avg_days_between_transactions,
    total_transactions_per_merchant as total_transactions,
    avg_trx_for_a_merchant_in_a_month as avg_monthly_transactions,
    months_active as tenure_months,
    ROUND(checkout_percentage, 2) as checkout_pct_of_revenue
    
FROM segmented_merchants
ORDER BY 
    CASE campaign_priority
        WHEN 'Phase 1 - Immediate' THEN 1
        WHEN 'Phase 2 - High Priority' THEN 2
        WHEN 'Phase 3 - Secondary Wave' THEN 3
        ELSE 4
    END,
    priority_score DESC,
    avg_monthly_volume_dollars DESC
    LIMIT 200;