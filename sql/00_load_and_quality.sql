-- Load Olist CSVs (DuckDB syntax. In Postgres use COPY ... FROM ... CSV HEADER)
CREATE OR REPLACE TABLE orders    AS SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');
CREATE OR REPLACE TABLE items     AS SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');
CREATE OR REPLACE TABLE customers AS SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');
CREATE OR REPLACE TABLE payments  AS SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');
CREATE OR REPLACE TABLE reviews   AS SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');
CREATE OR REPLACE TABLE products  AS SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');
CREATE OR REPLACE TABLE sellers   AS SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');
CREATE OR REPLACE TABLE cat_en    AS SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');

-- Quality checks
SELECT 'orders' t, COUNT(*) n_rows, COUNT(DISTINCT order_id) n_distinct FROM orders
UNION ALL SELECT 'reviews', COUNT(*), COUNT(DISTINCT order_id) FROM reviews;
SELECT order_status, COUNT(*) FROM orders GROUP BY 1 ORDER BY 2 DESC;
SELECT COUNT(*) AS delivered_missing_date FROM orders
 WHERE order_status='delivered' AND order_delivered_customer_date IS NULL;
SELECT COUNT(*) AS orders_without_payment FROM orders o
 WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE p.order_id=o.order_id);
SELECT COUNT(*) AS products_missing_category FROM products WHERE product_category_name IS NULL;
SELECT COUNT(*) AS delivered_before_purchase FROM orders
 WHERE order_delivered_customer_date < order_purchase_timestamp;
