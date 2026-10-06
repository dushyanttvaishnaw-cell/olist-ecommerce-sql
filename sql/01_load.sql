-- Run from the repo root with psql so \copy can find data/:
--   psql -d olist -f sql/01_load.sql
SET search_path TO olist;

\copy customers            FROM 'data/olist_customers_dataset.csv'           CSV HEADER
\copy sellers              FROM 'data/olist_sellers_dataset.csv'             CSV HEADER
\copy category_translation FROM 'data/product_category_name_translation.csv' CSV HEADER
\copy products             FROM 'data/olist_products_dataset.csv'            CSV HEADER
\copy orders               FROM 'data/olist_orders_dataset.csv'              CSV HEADER
\copy order_items          FROM 'data/olist_order_items_dataset.csv'         CSV HEADER
\copy order_payments       FROM 'data/olist_order_payments_dataset.csv'      CSV HEADER
\copy order_reviews        FROM 'data/olist_order_reviews_dataset.csv'       CSV HEADER

-- two categories are missing from the translation file
INSERT INTO category_translation VALUES
  ('pc_gamer', 'pc_gamer'),
  ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_preparers')
ON CONFLICT DO NOTHING;

ANALYZE;

SELECT 'customers' AS tbl, count(*) FROM customers UNION ALL
SELECT 'orders', count(*) FROM orders UNION ALL
SELECT 'order_items', count(*) FROM order_items UNION ALL
SELECT 'order_payments', count(*) FROM order_payments UNION ALL
SELECT 'order_reviews', count(*) FROM order_reviews UNION ALL
SELECT 'products', count(*) FROM products UNION ALL
SELECT 'sellers', count(*) FROM sellers;
