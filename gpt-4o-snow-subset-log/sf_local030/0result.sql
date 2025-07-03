WITH LowestPaymentCities AS (
    SELECT c."customer_city", 
           SUM(p."payment_value") AS "total_payment", 
           COUNT(o."order_id") AS "total_orders"
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
    ON c."customer_id" = o."customer_id"
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p
    ON o."order_id" = p."order_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_city"
    ORDER BY "total_payment" ASC
    LIMIT 5
)
SELECT AVG("total_payment") AS "average_payment", 
       AVG("total_orders") AS "average_orders"
FROM LowestPaymentCities;