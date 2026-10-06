-- Q: Which seller state -> customer state lanes are late the most?
-- Only lanes with 300+ delivered items so small samples don't dominate.
SET search_path TO olist;

SELECT
    i.seller_state || ' -> ' || i.customer_state                 AS lane,
    count(*)                                                     AS delivered_items,
    round(100.0 * avg(o.is_late::int), 1)                        AS late_pct,
    round(avg(o.days_to_deliver), 1)                             AS avg_days,
    round(avg(i.freight_value), 2)                               AS avg_freight_brl
FROM v_items i
JOIN v_orders o USING (order_id)
WHERE o.delivered_customer_at IS NOT NULL
GROUP BY 1
HAVING count(*) >= 300
ORDER BY late_pct DESC
LIMIT 12;
