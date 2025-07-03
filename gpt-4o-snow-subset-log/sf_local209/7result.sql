WITH StoreOrderCounts AS (
    SELECT 
        "store_id", 
        COUNT("order_id") AS "total_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS
    GROUP BY "store_id"
    ORDER BY "total_orders" DESC NULLS LAST
    LIMIT 1
),
DeliveredOrders AS (
    SELECT 
        o."store_id",
        COUNT(o."order_id") AS "delivered_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS AS o
    LEFT JOIN DELIVERY_CENTER.DELIVERY_CENTER.DELIVERIES AS d
    ON o."delivery_order_id" = d."delivery_order_id"
    WHERE d."delivery_status" = 'DELIVERED'
    GROUP BY o."store_id"
),
FinalCalculation AS (
    SELECT 
        s."store_id",
        (COALESCE(d."delivered_orders", 0) * 1.0) / s."total_orders" AS "delivered_to_total_ratio"
    FROM StoreOrderCounts AS s
    LEFT JOIN DeliveredOrders AS d
    ON s."store_id" = d."store_id"
)
SELECT * 
FROM FinalCalculation;