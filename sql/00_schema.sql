-- Olist Brazilian e-commerce, 2016 to 2018
-- Raw tables, kept close to the source files. Cleanup happens in views (02).

DROP SCHEMA IF EXISTS olist CASCADE;
CREATE SCHEMA olist;
SET search_path TO olist;

CREATE TABLE customers (
    customer_id         TEXT PRIMARY KEY,   -- one per ORDER, not per person (see README)
    customer_unique_id  TEXT NOT NULL,      -- the actual person
    zip_prefix          TEXT,
    city                TEXT,
    state               CHAR(2)
);

CREATE TABLE sellers (
    seller_id   TEXT PRIMARY KEY,
    zip_prefix  TEXT,
    city        TEXT,
    state       CHAR(2)
);

CREATE TABLE category_translation (
    category_pt  TEXT PRIMARY KEY,
    category_en  TEXT
);

CREATE TABLE products (
    product_id          TEXT PRIMARY KEY,
    category_pt         TEXT,
    name_length         INT,     -- source file spells it "lenght"
    description_length  INT,
    photos_qty          INT,
    weight_g            INT,
    length_cm           INT,
    height_cm           INT,
    width_cm            INT
);

CREATE TABLE orders (
    order_id                  TEXT PRIMARY KEY,
    customer_id               TEXT NOT NULL REFERENCES customers(customer_id),
    status                    TEXT,
    purchased_at              TIMESTAMP,
    approved_at               TIMESTAMP,
    delivered_carrier_at      TIMESTAMP,
    delivered_customer_at     TIMESTAMP,
    estimated_delivery_date   TIMESTAMP
);

CREATE TABLE order_items (
    order_id             TEXT REFERENCES orders(order_id),
    order_item_id        INT,
    product_id           TEXT REFERENCES products(product_id),
    seller_id            TEXT REFERENCES sellers(seller_id),
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC(10,2),
    freight_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id              TEXT REFERENCES orders(order_id),
    payment_sequential    INT,
    payment_type          TEXT,
    payment_installments  INT,
    payment_value         NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- review_id is NOT unique in the source (some reviews are attached to
-- several orders), so no PK on it alone.
CREATE TABLE order_reviews (
    review_id          TEXT,
    order_id           TEXT REFERENCES orders(order_id),
    review_score       SMALLINT CHECK (review_score BETWEEN 1 AND 5),
    comment_title      TEXT,
    comment_message    TEXT,
    created_at         TIMESTAMP,
    answered_at        TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);

CREATE INDEX ix_orders_customer   ON orders(customer_id);
CREATE INDEX ix_orders_purchased  ON orders(purchased_at);
CREATE INDEX ix_items_product     ON order_items(product_id);
CREATE INDEX ix_items_seller      ON order_items(seller_id);
CREATE INDEX ix_customers_unique  ON customers(customer_unique_id);
