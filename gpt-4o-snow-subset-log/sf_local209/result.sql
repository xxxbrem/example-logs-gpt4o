WITH StoreOrderCounts AS (
    SELECT 
        o."store_id", 
        COUNT(*) AS "total_orders"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    GROUP BY 
        o."store_id"
    ORDER BY 
        "total_orders" DESC NULLS LAST
    LIMIT 1
), DeliveredOrders AS (
    SELECT 
        o."store_id", 
        COUNT(*) AS "delivered_orders"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    JOIN 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" d
    ON 
        o."delivery_order_id" = d."delivery_order_id"
    WHERE 
        d."delivery_status" = 'DELIVERED'
    GROUP BY 
        o."store_id"
)
SELECT 
    soc."store_id", 
    soc."total_orders", 
    do."delivered_orders", 
    (do."delivered_orders"::FLOAT / soc."total_orders"::FLOAT) AS "completed_to_total_ratio"
FROM 
    StoreOrderCounts soc
LEFT JOIN 
    DeliveredOrders do
ON 
    soc."store_id" = do."store_id";