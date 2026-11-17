-- Top categories by revenue with rating and share
WITH r AS (SELECT order_id, AVG(review_score) s FROM reviews GROUP BY 1)
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') category,
       ROUND(SUM(i.price),0) revenue,
       ROUND(100.0*SUM(i.price)/SUM(SUM(i.price)) OVER (),1) pct_revenue,
       COUNT(DISTINCT i.order_id) orders,
       ROUND(AVG(r.s),2) avg_review
FROM items i JOIN orders o USING(order_id)
JOIN products p USING(product_id)
LEFT JOIN cat_en t ON t.product_category_name=p.product_category_name
LEFT JOIN r ON r.order_id=i.order_id
WHERE o.order_status='delivered'
GROUP BY 1 ORDER BY revenue DESC LIMIT 10;
