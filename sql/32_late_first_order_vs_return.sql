-- Q: Does a late FIRST delivery make a customer less likely to come back?
-- This connects the logistics side to retention.
-- Includes a two proportion z-test, done in SQL so the whole answer lives in one query.
SET search_path TO olist;

WITH totals AS (
    -- count order DAYS, so a split cart on the same day doesn't count as coming back
    SELECT customer, count(DISTINCT purchased_at::date) AS total_orders
    FROM v_orders
    GROUP BY customer
),
first_orders AS (
    SELECT DISTINCT ON (customer) customer, order_month, is_late, review_score
    FROM v_orders
    ORDER BY customer, purchased_at, order_id
),
grp AS (
    SELECT
        f.is_late,
        count(*)                                     AS customers,
        count(*) FILTER (WHERE t.total_orders >= 2)  AS came_back,
        avg(f.review_score)                          AS avg_first_review
    FROM first_orders f
    JOIN totals t USING (customer)
    WHERE f.is_late IS NOT NULL                                -- first order was delivered
      AND f.order_month BETWEEN '2017-01-01' AND '2018-02-01'  -- 6+ months to come back
    GROUP BY f.is_late
),
pooled AS (
    SELECT sum(came_back)::numeric / sum(customers) AS p FROM grp
)
SELECT
    CASE WHEN g.is_late THEN 'first order late' ELSE 'first order on time' END AS first_delivery,
    g.customers,
    g.came_back,
    round(100.0 * g.came_back / g.customers, 2)  AS came_back_pct,
    round(g.avg_first_review, 2)                 AS avg_first_review,
    -- z for (late rate - on time rate); same value on both rows
    round(( (SELECT came_back::numeric / customers FROM grp WHERE is_late)
          - (SELECT came_back::numeric / customers FROM grp WHERE NOT is_late) )
          / sqrt(p.p * (1 - p.p) * ( 1.0 / (SELECT customers FROM grp WHERE is_late)
                                   + 1.0 / (SELECT customers FROM grp WHERE NOT is_late))), 2) AS z_stat
FROM grp g CROSS JOIN pooled p
ORDER BY 1;
