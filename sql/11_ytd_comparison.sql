-- Q: Jan to Aug 2018 vs Jan to Aug 2017. How much of the growth is more orders
-- vs bigger orders?
SET search_path TO olist;

SELECT
    extract(year FROM order_month)::int     AS yr,
    count(*)                                AS orders,
    count(DISTINCT customer)                AS customers,
    round(sum(gmv))                         AS gmv_brl,
    round(avg(gmv), 2)                      AS avg_order_value,
    round(avg(items), 2)                    AS avg_items_per_order,
    round(100.0 * sum(freight) / sum(gmv), 1) AS freight_share_pct
FROM v_orders
WHERE extract(month FROM order_month) BETWEEN 1 AND 8
  AND extract(year  FROM order_month) IN (2017, 2018)
GROUP BY 1
ORDER BY 1;
