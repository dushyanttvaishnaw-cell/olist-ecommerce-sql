-- Q: How much does a late delivery hurt the review score?
SET search_path TO olist;

WITH d AS (
    SELECT review_score,
           (delivered_customer_at::date - estimated_delivery_date::date) AS days_vs_estimate
    FROM v_orders
    WHERE delivered_customer_at IS NOT NULL
      AND review_score IS NOT NULL
)
SELECT
    CASE
        WHEN days_vs_estimate <= -7 THEN '1. 7+ days early'
        WHEN days_vs_estimate <= 0  THEN '2. 0-6 days early'
        WHEN days_vs_estimate <= 3  THEN '3. 1-3 days late'
        WHEN days_vs_estimate <= 7  THEN '4. 4-7 days late'
        ELSE                             '5. 8+ days late'
    END                                                       AS delivery_bucket,
    count(*)                                                  AS orders,
    round(avg(review_score), 2)                               AS avg_review,
    round(100.0 * avg((review_score = 1)::int), 1)            AS one_star_pct,
    round(100.0 * avg((review_score >= 4)::int), 1)           AS four_plus_pct
FROM d
GROUP BY 1
ORDER BY 1;
