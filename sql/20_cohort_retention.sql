-- Q: Of the customers who first bought in a given month, what % came back
-- in each later month?
--
-- Uses customer_unique_id. The table also has customer_id, but Olist issues a
-- new customer_id on every order, so a cohort built on it shows 0% retention
-- no matter what. I made that mistake first.
SET search_path TO olist;

WITH firsts AS (
    SELECT customer, min(order_month) AS cohort
    FROM v_orders
    GROUP BY customer
),
activity AS (
    SELECT DISTINCT
           f.cohort,
           v.customer,
           (extract(year FROM age(v.order_month, f.cohort)) * 12
            + extract(month FROM age(v.order_month, f.cohort)))::int AS month_n
    FROM v_orders v
    JOIN firsts f USING (customer)
),
sizes AS (
    SELECT cohort, count(*) AS cohort_size FROM firsts GROUP BY cohort
)
SELECT
    a.cohort,
    s.cohort_size,
    round(100.0 * count(*) FILTER (WHERE month_n = 1)  / s.cohort_size, 2) AS m1,
    round(100.0 * count(*) FILTER (WHERE month_n = 2)  / s.cohort_size, 2) AS m2,
    round(100.0 * count(*) FILTER (WHERE month_n = 3)  / s.cohort_size, 2) AS m3,
    round(100.0 * count(*) FILTER (WHERE month_n = 4)  / s.cohort_size, 2) AS m4,
    round(100.0 * count(*) FILTER (WHERE month_n = 5)  / s.cohort_size, 2) AS m5,
    round(100.0 * count(*) FILTER (WHERE month_n = 6)  / s.cohort_size, 2) AS m6,
    round(100.0 * count(*) FILTER (WHERE month_n BETWEEN 1 AND 6) / s.cohort_size, 2) AS any_m1_to_m6,
    round(100.0 * count(DISTINCT customer) FILTER (WHERE month_n >= 1) / s.cohort_size, 2) AS ever_returned
FROM activity a
JOIN sizes s USING (cohort)
WHERE a.cohort BETWEEN '2017-01-01' AND '2018-02-01'   -- need 6 months of runway
GROUP BY a.cohort, s.cohort_size
ORDER BY a.cohort;
