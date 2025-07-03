SELECT 
    c."customer_id", 
    COUNT(o."order_id") AS "number_of_orders", 
    AVG(p."payment_value") AS "avg_payment_per_order", 
    CASE 
        WHEN DATEDIFF('day', MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 < 1 THEN 1.0
        ELSE CAST(DATEDIFF('day', MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 AS FLOAT)
    END AS "customer_lifespan_in_weeks"
FROM E_COMMERCE.E_COMMERCE.CUSTOMERS c
JOIN E_COMMERCE.E_COMMERCE.ORDERS o
    ON c."customer_id" = o."customer_id"
JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS p
    ON o."order_id" = p."order_id"
GROUP BY c."customer_id"
ORDER BY "avg_payment_per_order" DESC NULLS LAST
LIMIT 3;