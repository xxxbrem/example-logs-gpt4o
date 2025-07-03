WITH StoreOrderCounts AS (
    SELECT 
        s."store_name",
        s."store_id",
        COUNT(o."order_id") AS "total_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.STORES s
    JOIN DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    ON s."store_id" = o."store_id"
    GROUP BY s."store_name", s."store_id"
    ORDER BY "total_orders" DESC NULLS LAST
    LIMIT 1
),
CompletedOrderRatio AS (
    SELECT 
        COUNT(CASE WHEN d."delivery_status" = 'DELIVERED' THEN 1 END) * 1.0 /
        COUNT(o."order_id") AS "completion_ratio"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    LEFT JOIN DELIVERY_CENTER.DELIVERY_CENTER.DELIVERIES d
    ON o."delivery_order_id" = d."delivery_order_id"
    WHERE o."store_id" = (SELECT "store_id" FROM StoreOrderCounts)
)
SELECT 
    so."store_name",
    so."total_orders",
    cor."completion_ratio"
FROM StoreOrderCounts so, CompletedOrderRatio cor;