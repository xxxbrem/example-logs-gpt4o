WITH CustomerStats AS (
    SELECT c."customer_unique_id", 
           COUNT(o."order_id") AS "order_count", 
           AVG(p."payment_value") AS "avg_payment_per_order", 
           DATEDIFF('day', MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 AS "lifespan_in_weeks"
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS c
    JOIN E_COMMERCE.E_COMMERCE.ORDERS o 
    ON c."customer_id" = o."customer_id"
    JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS p 
    ON o."order_id" = p."order_id"
    GROUP BY c."customer_unique_id"
)
SELECT "customer_unique_id", 
       "order_count", 
       ROUND("avg_payment_per_order", 4) AS "average_payment_per_order", 
       CASE 
           WHEN "lifespan_in_weeks" < 1 THEN 1.0 
           ELSE ROUND("lifespan_in_weeks", 4) 
       END AS "customer_lifespan_in_weeks"
FROM CustomerStats
ORDER BY "average_payment_per_order" DESC NULLS LAST
LIMIT 3;