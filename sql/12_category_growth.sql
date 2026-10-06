-- Q: Which categories drive revenue, and which ones grew fastest (Jan-Aug, 2018 vs 2017)?
SET search_path TO olist;

WITH cat AS (
    SELECT category,
           sum(price) FILTER (WHERE order_month BETWEEN '2017-01-01' AND '2017-08-01') AS rev_2017,
           sum(price) FILTER (WHERE order_month BETWEEN '2018-01-01' AND '2018-08-01') AS rev_2018
    FROM v_items
    GROUP BY category
)
SELECT
    dense_rank() OVER (ORDER BY rev_2018 DESC NULLS LAST)        AS rank_2018,
    category,
    round(rev_2017)                                              AS rev_2017,
    round(rev_2018)                                              AS rev_2018,
    round(100.0 * (rev_2018 / nullif(rev_2017, 0) - 1), 1)       AS growth_pct,
    round(100.0 * rev_2018 / sum(rev_2018) OVER (), 1)           AS share_2018_pct,
    round(100.0 * sum(rev_2018) OVER (ORDER BY rev_2018 DESC NULLS LAST)
                 / sum(rev_2018) OVER (), 1)                     AS cumulative_share_pct
FROM cat
WHERE rev_2018 IS NOT NULL
ORDER BY rev_2018 DESC
LIMIT 15;
