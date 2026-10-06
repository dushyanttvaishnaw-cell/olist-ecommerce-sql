-- Q: How do people pay, and do installments go with bigger orders?
SET search_path TO olist;

WITH p AS (
    SELECT op.order_id, op.payment_type, op.payment_installments, op.payment_value
    FROM order_payments op
    JOIN v_orders vo USING (order_id)
    WHERE op.payment_sequential = 1
)
SELECT
    payment_type,
    CASE WHEN payment_type <> 'credit_card' THEN '-'
         WHEN payment_installments <= 1 THEN '1 (paid in full)'
         WHEN payment_installments <= 4 THEN '2-4'
         WHEN payment_installments <= 8 THEN '5-8'
         ELSE '9+' END                                       AS installments,
    count(*)                                                 AS orders,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1)       AS share_pct,
    round(avg(payment_value), 2)                             AS avg_payment
FROM p
GROUP BY 1, 2
ORDER BY orders DESC;
