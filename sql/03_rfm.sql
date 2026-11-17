-- RFM segmentation with NTILE, plus share of revenue by segment
WITH base AS (
  SELECT c.customer_unique_id cid, o.order_id, o.order_purchase_timestamp ts,
         SUM(i.price+i.freight_value) amt
  FROM orders o JOIN customers c USING(customer_id) JOIN items i USING(order_id)
  WHERE o.order_status='delivered' GROUP BY 1,2,3),
rfm AS (
  SELECT cid,
         date_diff('day', MAX(ts), (SELECT MAX(ts) FROM base)) recency_days,
         COUNT(*) frequency, SUM(amt) monetary
  FROM base GROUP BY cid),
scored AS (
  SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC, cid) r,
            NTILE(5) OVER (ORDER BY monetary, cid) m
  FROM rfm),
seg AS (
  SELECT *, CASE
     WHEN frequency>1 AND r>=4 THEN 'Loyal (repeat + recent)'
     WHEN m=5 AND r>=3 THEN 'High value, recent'
     WHEN m=5 AND r<=2 THEN 'High value, at risk'
     WHEN r<=2 THEN 'Lapsed low value'
     ELSE 'Recent low/mid value' END segment
  FROM scored)
SELECT segment, COUNT(*) customers,
       ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) pct_customers,
       ROUND(100.0*SUM(monetary)/SUM(SUM(monetary)) OVER (),1) pct_revenue,
       ROUND(AVG(monetary),0) avg_spend
FROM seg GROUP BY 1 ORDER BY pct_revenue DESC;
