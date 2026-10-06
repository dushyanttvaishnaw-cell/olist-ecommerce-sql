-- Q: How did revenue and order volume trend month to month?
-- Window: Jan 2017 to Aug 2018. 2016 has a few hundred test-looking orders,
-- and Sep/Oct 2018 is where the export cuts off.
SET search_path TO olist;

WITH monthly AS (
    SELECT order_month,
           count(*)                    AS orders,
           count(DISTINCT customer)    AS customers,
           sum(gmv)                    AS gmv,
           round(avg(gmv), 2)          AS avg_order_value
    FROM v_orders
    WHERE order_month BETWEEN '2017-01-01' AND '2018-08-01'
    GROUP BY order_month
)
SELECT
    order_month,
    orders,
    customers,
    round(gmv)                                                         AS gmv_brl,
    avg_order_value,
    round(100.0 * (gmv / lag(gmv) OVER (ORDER BY order_month) - 1), 1) AS gmv_mom_pct,
    round(avg(gmv) OVER (ORDER BY order_month
                         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW))     AS gmv_3mo_avg,
    -- same month last year (only exists for 2018)
    round(100.0 * (gmv / lag(gmv, 12) OVER (ORDER BY order_month) - 1), 1) AS gmv_yoy_pct
FROM monthly
ORDER BY order_month;
