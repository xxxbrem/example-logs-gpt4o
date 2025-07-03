WITH TopStore AS (
    -- Find store with the highest number of total orders
    SELECT 
        "store_id",
        COUNT(*) AS "total_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER."ORDERS"
    GROUP BY "store_id"
    ORDER BY "total_orders" DESC NULLS LAST
    LIMIT 1
),
DeliveredOrders AS (
    -- Count delivered orders for the top store
    SELECT 
        COUNT(o."order_id") AS "delivered_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER."ORDERS" o
    LEFT JOIN DELIVERY_CENTER.DELIVERY_CENTER."DELIVERIES" d
        ON o."delivery_order_id" = d."delivery_order_id"
    WHERE o."store_id" = (SELECT "store_id" FROM TopStore)
      AND d."delivery_status" = 'DELIVERED'
),
TotalOrders AS (
    -- Count total orders for the top store
    SELECT 
        COUNT(o."order_id") AS "total_orders_for_store"
    FROM DELIVERY_CENTER.DELIVERY_CENTER."ORDERS" o
    WHERE o."store_id" = (SELECT "store_id" FROM TopStore)
)
-- Compute the ratio of delivered orders to total orders
SELECT 
    delivered."delivered_orders",
    total."total_orders_for_store",
    (delivered."delivered_orders" * 1.0 / total."total_orders_for_store") AS "delivery_ratio"
FROM DeliveredOrders delivered, TotalOrders total;