WITH lowest_payment_cities AS (
  SELECT c."customer_city", 
         SUM(p."payment_value") AS "total_payment", 
         COUNT(DISTINCT o."order_id") AS "delivered_order_count"
  FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
  JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p
  ON o."order_id" = p."order_id"
  JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
  ON o."customer_id" = c."customer_id"
  WHERE o."order_status" = 'delivered'
  GROUP BY c."customer_city"
  ORDER BY SUM(p."payment_value") ASC
  LIMIT 5
)
SELECT AVG("total_payment") AS "average_payment", 
       AVG("delivered_order_count") AS "average_order_count"
FROM lowest_payment_cities;