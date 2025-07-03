SELECT TOP 3 
    c."customer_id", 
    COUNT(o."order_id") AS "order_count",
    AVG(op."payment_value") AS "avg_payment_per_order",
    CASE 
        WHEN DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 < 1.0 THEN 1.0
        ELSE DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0
    END AS "lifespan_weeks"
FROM "E_COMMERCE"."E_COMMERCE"."CUSTOMERS" c
JOIN "E_COMMERCE"."E_COMMERCE"."ORDERS" o
ON c."customer_id" = o."customer_id"
JOIN "E_COMMERCE"."E_COMMERCE"."ORDER_PAYMENTS" op
ON o."order_id" = op."order_id"
GROUP BY c."customer_id"
ORDER BY "avg_payment_per_order" DESC NULLS LAST;