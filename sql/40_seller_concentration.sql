-- Q: How concentrated is revenue across sellers?
SET search_path TO olist;

WITH s AS (
    SELECT seller_id, sum(price) AS revenue
    FROM v_items
    GROUP BY seller_id
),
d AS (
    SELECT seller_id, revenue, ntile(10) OVER (ORDER BY revenue DESC) AS decile
    FROM s
)
SELECT
    decile,
    count(*)                                               AS sellers,
    round(sum(revenue))                                    AS revenue_brl,
    round(100.0 * sum(revenue) / sum(sum(revenue)) OVER (), 1)               AS share_pct,
    round(100.0 * sum(sum(revenue)) OVER (ORDER BY decile)
                 / sum(sum(revenue)) OVER (), 1)                             AS cumulative_pct,
    round(min(revenue))                                    AS min_seller_rev,
    round(max(revenue))                                    AS max_seller_rev
FROM d
GROUP BY decile
ORDER BY decile;
