-- Analysis layer. Everything downstream reads from these views, not the raw tables.
SET search_path TO olist;

-- One row per order with the person (customer_unique_id), money, delivery and review.
-- Canceled / unavailable orders are excluded here so nobody has to remember to filter them.
CREATE OR REPLACE VIEW v_orders AS
WITH items AS (
    SELECT order_id,
           count(*)            AS items,
           sum(price)          AS product_revenue,
           sum(freight_value)  AS freight
    FROM order_items
    GROUP BY order_id
),
reviews AS (
    -- a handful of orders have more than one review; keep the latest
    SELECT DISTINCT ON (order_id) order_id, review_score
    FROM order_reviews
    ORDER BY order_id, answered_at DESC NULLS LAST, review_id
)
SELECT
    o.order_id,
    c.customer_unique_id                        AS customer,
    c.state                                     AS customer_state,
    o.status,
    o.purchased_at,
    date_trunc('month', o.purchased_at)::date   AS order_month,
    i.items,
    i.product_revenue,
    i.freight,
    i.product_revenue + i.freight               AS gmv,
    o.delivered_customer_at,
    o.estimated_delivery_date,
    CASE WHEN o.delivered_customer_at IS NOT NULL
         THEN round(extract(epoch FROM o.delivered_customer_at - o.purchased_at) / 86400.0, 1) END
                                                AS days_to_deliver,
    CASE WHEN o.delivered_customer_at IS NOT NULL
         THEN o.delivered_customer_at::date > o.estimated_delivery_date::date END
                                                AS is_late,
    r.review_score
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN items     i ON i.order_id    = o.order_id      -- 775 orders have no items (almost all canceled)
LEFT JOIN reviews r ON r.order_id = o.order_id
WHERE o.status NOT IN ('canceled', 'unavailable');

-- Item level with English category + seller, for category and seller questions.
CREATE OR REPLACE VIEW v_items AS
SELECT
    oi.order_id,
    vo.order_month,
    vo.customer,
    vo.customer_state,
    oi.product_id,
    coalesce(t.category_en, 'unknown')  AS category,
    oi.seller_id,
    s.state                             AS seller_state,
    oi.price,
    oi.freight_value
FROM order_items oi
JOIN v_orders vo ON vo.order_id = oi.order_id
JOIN products p  ON p.product_id = oi.product_id
JOIN sellers  s  ON s.seller_id  = oi.seller_id
LEFT JOIN category_translation t ON t.category_pt = p.category_pt;
