-- Q: Are orders getting to customers on time, and is it getting better or worse?
-- On time = delivered on or before the estimated date shown at checkout.
SET search_path TO olist;

SELECT
    order_month,
    count(*)                                                     AS delivered_orders,
    round(100.0 * avg((NOT is_late)::int), 1)                    AS on_time_pct,
    round(avg(days_to_deliver), 1)                               AS avg_days,
    round(percentile_cont(0.9) WITHIN GROUP (ORDER BY days_to_deliver)::numeric, 1) AS p90_days,
    round(avg(extract(epoch FROM estimated_delivery_date - delivered_customer_at) / 86400.0), 1)
                                                                 AS avg_days_early
FROM v_orders
WHERE delivered_customer_at IS NOT NULL
  AND order_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY order_month
ORDER BY order_month;
