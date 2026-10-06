-- Q: How many customers ever order twice, how long until they do, and how
-- much of revenue comes from them?
SET search_path TO olist;

WITH per_customer AS (
    SELECT customer,
           count(*)                                           AS orders,
           sum(gmv)                                           AS gmv,
           min(purchased_at)                                  AS first_at,
           (array_agg(purchased_at ORDER BY purchased_at))[2] AS second_at
    FROM v_orders
    GROUP BY customer
)
SELECT
    count(*)                                                          AS customers,
    count(*) FILTER (WHERE orders >= 2)                               AS repeat_customers,
    round(100.0 * count(*) FILTER (WHERE orders >= 2) / count(*), 2)  AS repeat_rate_pct,
    -- a lot of "repeats" are a second checkout the same day (split cart), not a return visit
    count(*) FILTER (WHERE orders >= 2 AND second_at::date = first_at::date) AS same_day_repeats,
    round(100.0 * count(*) FILTER (WHERE orders >= 2 AND second_at::date > first_at::date)
                / count(*), 2)                                        AS true_repeat_rate_pct,
    round(100.0 * sum(gmv) FILTER (WHERE orders >= 2) / sum(gmv), 1)  AS repeat_share_of_gmv_pct,
    round((percentile_cont(0.5) WITHIN GROUP (
        ORDER BY extract(epoch FROM second_at - first_at) / 86400.0)
        FILTER (WHERE orders >= 2 AND second_at::date > first_at::date))::numeric, 0)
                                                                      AS median_days_to_2nd_order
FROM per_customer;
