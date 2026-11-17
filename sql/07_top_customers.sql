-- What share of revenue comes from the top 20% of customers by spend? (delivered orders)
WITH spend AS (
  SELECT c.customer_unique_id cid, SUM(i.price + i.freight_value) amt
  FROM orders o JOIN customers c USING (customer_id) JOIN items i USING (order_id)
  WHERE o.order_status = 'delivered'
  GROUP BY 1),
ranked AS (
  SELECT amt, ROW_NUMBER() OVER (ORDER BY amt DESC, cid) rn, COUNT(*) OVER () n
  FROM spend)
SELECT COUNT(*) AS customers,
       ROUND(100.0 * SUM(CASE WHEN rn <= 0.2 * n THEN amt END) / SUM(amt), 1) AS top20_pct_revenue
FROM ranked;
