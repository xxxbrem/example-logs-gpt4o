SELECT DISTINCT c."customer_id", 
       c."customer_city", 
       c."customer_state", 
       t."number_of_orders", 
       t."average_payment_per_order", 
       t."customer_lifespan_weeks"
FROM (
    SELECT o."customer_id",
           COUNT(o."order_id") AS "number_of_orders",
           (SUM(p."payment_value") / COUNT(p."order_id")) AS "average_payment_per_order",
           CASE
               WHEN DATEDIFF('DAY', MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 < 1 
               THEN 1.0
               ELSE DATEDIFF('DAY', MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0
           END AS "customer_lifespan_weeks"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS p
    ON o."order_id" = p."order_id"
    GROUP BY o."customer_id"
    ORDER BY "average_payment_per_order" DESC NULLS LAST
    LIMIT 3
) t
JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS c
ON t."customer_id" = c."customer_id";