# Every number on the CV, and how to reproduce it

| CV claim | Value | Where it comes from |
| --- | --- | --- |
| Orders analyzed | 99,441 | `sql/00`: `SELECT COUNT(*) FROM orders` |
| Tables used | 8 | `sql/00` loads 8 CSVs |
| Avg rating, 8+ days late vs on time | 1.70 vs 4.29 | `sql/04`: bucket `days_late` = delivered date minus estimated date, `AVG(review_score)` per bucket, latest review per order |
| Late-delivery rate RJ vs SP | 13.5% vs 5.9% | `sql/05`: share of delivered orders where delivered date > estimated date, by customer state |
| Repeat customers | 3.0% of 93,358 | `sql/02`: customers (by `customer_unique_id`) with 2+ delivered orders |
| Top 20% of customers' revenue share | 53.5% | `sql/07`: rank customers by total spend, sum the top 20% |
| Data-quality issues | 99,224 reviews for 98,673 orders, 8 delivered orders with no date, 1 order with no payment | `sql/00` |
