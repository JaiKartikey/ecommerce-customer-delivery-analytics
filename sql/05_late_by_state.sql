-- Late-delivery rate by customer state (states with 1000+ orders)
SELECT c.customer_state state, COUNT(*) orders,
       ROUND(100.0*AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END),1) late_pct,
       ROUND(AVG(date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date)),1) avg_delivery_days
FROM orders o JOIN customers c USING(customer_id)
WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1 HAVING COUNT(*)>=1000 ORDER BY late_pct DESC;
