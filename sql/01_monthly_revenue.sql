-- Monthly revenue (item price + freight) for delivered orders, with MoM growth via LAG
WITH m AS (
  SELECT date_trunc('month', o.order_purchase_timestamp) AS month,
         COUNT(DISTINCT o.order_id) AS orders,
         SUM(i.price + i.freight_value) AS revenue
  FROM orders o JOIN items i USING (order_id)
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= DATE '2017-01-01'  -- 2016 has too few orders to trend
  GROUP BY 1)
SELECT month, orders, ROUND(revenue,0) AS revenue,
       ROUND(revenue/orders,2) AS aov,
       ROUND(100.0*(revenue - LAG(revenue) OVER (ORDER BY month))/LAG(revenue) OVER (ORDER BY month),1) AS mom_growth_pct
FROM m ORDER BY month;
