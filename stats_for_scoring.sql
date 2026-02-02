/* Average Transactions in a month */

SELECT 
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month) as p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month) as p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month) as p95
from recurring_merchants
where avg_trx_for_a_merchant_in_a_month > 0


/*Average Monthly Checkout Dollars*/

SELECT 
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars) as p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars) as p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars) as p95
from recurring_merchants
where avg_monthly_checkout_dollars > 0


/*Average Monthly Volume Dollars*/
SELECT 
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars) as p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars) as p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars) as p95
FROM final



/*Unioning all the factors for Target Scoring */



                                    /*Percentile Threshholds*/
SELECT 
    'avg_monthly_volume_dollars' as metric,
    ROUND(CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars)AS NUMERIC), 2) as p75_threshold,
    ROUND(CAST(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_monthly_volume_dollars) AS NUMERIC), 2) as p90_threshold
FROM recurring_merchants
WHERE avg_monthly_volume_dollars > 0

UNION ALL

SELECT 
    'avg_monthly_checkout_dollars' as metric,
    ROUND(CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars)AS NUMERIC), 2) as p75_threshold,
    ROUND(CAST(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_monthly_checkout_dollars)AS NUMERIC), 2) as p90_threshold
FROM recurring_merchants
WHERE avg_monthly_checkout_dollars > 0

UNION ALL

SELECT 
    'avg_trx_per_month' as metric,
    ROUND(CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month)AS NUMERIC), 2) as p75_threshold,
    ROUND(CAST(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY avg_trx_for_a_merchant_in_a_month)AS NUMERIC), 2) as p90_threshold
FROM recurring_merchants
WHERE avg_trx_for_a_merchant_in_a_month > 0;