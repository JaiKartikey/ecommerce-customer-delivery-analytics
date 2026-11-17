-- Does late delivery hurt ratings? (one review per order: take latest)
WITH r AS (
  SELECT order_id, review_score,
         ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) rn
  FROM reviews),
d AS (
  SELECT o.order_id,
         date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) days_late
  FROM orders o
  WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL)
SELECT CASE WHEN days_late<=0 THEN '1. On time / early'
            WHEN days_late<=7 THEN '2. 1-7 days late'
            ELSE '3. 8+ days late' END bucket,
       COUNT(*) orders,
       ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) pct_orders,
       ROUND(AVG(review_score),2) avg_review,
       ROUND(100.0*AVG(CASE WHEN review_score<=2 THEN 1 ELSE 0 END),1) pct_1_2_star
FROM d JOIN r USING(order_id) WHERE rn=1
GROUP BY 1 ORDER BY 1;
