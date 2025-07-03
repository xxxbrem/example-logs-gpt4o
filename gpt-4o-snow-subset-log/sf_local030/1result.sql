WITH CityPayments AS (
  SELECT c."customer_city", 
         SUM(p."payment_value") AS "total_payment"
  FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
  JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
  ON o."customer_id" = c."customer_id"
  JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p
  ON o."order_id" = p."order_id"
  WHERE o."order_status" = 'delivered'
  GROUP BY c."customer_city"
  ORDER BY "total_payment" ASC
  LIMIT 5
),
CityOrders AS (
  SELECT c."customer_city", 
         COUNT(o."order_id") AS "total_orders"
  FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
  JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
  ON o."customer_id" = c."customer_id"
  WHERE c."customer_city" IN (SELECT "customer_city" FROM CityPayments)
  AND o."order_status" = 'delivered'
  GROUP BY c."customer_city"
)
SELECT AVG(cp."total_payment") AS "avg_total_payment", 
       AVG(co."total_orders") AS "avg_total_orders"
FROM CityPayments cp
JOIN CityOrders co
ON cp."customer_city" = co."customer_city";