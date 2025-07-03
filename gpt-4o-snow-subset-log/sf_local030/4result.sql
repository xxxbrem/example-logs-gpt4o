SELECT 
    AVG("total_payment") AS "average_total_payment", 
    AVG("delivered_order_count") AS "average_delivered_order_count"
FROM (
    SELECT 
        c."customer_city", 
        SUM(p."payment_value") AS "total_payment", 
        COUNT(o."order_id") AS "delivered_order_count"
    FROM "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_CUSTOMERS" c
    JOIN "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS" o
    ON c."customer_id" = o."customer_id"
    JOIN "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDER_PAYMENTS" p
    ON o."order_id" = p."order_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_city"
    ORDER BY SUM(p."payment_value") ASC
    LIMIT 5
) subquery;