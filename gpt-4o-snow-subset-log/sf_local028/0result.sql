SELECT
  MONTH(TO_TIMESTAMP("order_purchase_timestamp")) AS "purchase_month",
  SUM(CASE WHEN YEAR(TO_TIMESTAMP("order_purchase_timestamp")) = 2016 THEN 1 ELSE 0 END) AS "2016_orders",
  SUM(CASE WHEN YEAR(TO_TIMESTAMP("order_purchase_timestamp")) = 2017 THEN 1 ELSE 0 END) AS "2017_orders",
  SUM(CASE WHEN YEAR(TO_TIMESTAMP("order_purchase_timestamp")) = 2018 THEN 1 ELSE 0 END) AS "2018_orders"
FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS
WHERE "order_status" = 'delivered'
GROUP BY "purchase_month"
ORDER BY "purchase_month";