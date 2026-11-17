-- customer_id is per-order in Olist, customer_unique_id is the real person
WITH per_cust AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) n_orders
  FROM orders o JOIN customers c USING (customer_id)
  WHERE o.order_status='delivered' GROUP BY 1)
SELECT COUNT(*) customers,
       SUM(CASE WHEN n_orders>1 THEN 1 ELSE 0 END) repeat_customers,
       ROUND(100.0*AVG(CASE WHEN n_orders>1 THEN 1 ELSE 0 END),2) repeat_rate_pct
FROM per_cust;
