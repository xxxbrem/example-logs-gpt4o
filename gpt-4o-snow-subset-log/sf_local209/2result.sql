WITH TopStore AS (
    -- Identify the store with the highest number of orders
    SELECT a."store_id"
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" a
    GROUP BY a."store_id"
    ORDER BY COUNT(a."order_id") DESC NULLS LAST
    LIMIT 1
),
TotalOrders AS (
    -- Count total number of orders for the top store
    SELECT COUNT("order_id") AS total_orders
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    WHERE o."store_id" = (SELECT "store_id" FROM TopStore)
),
DeliveredOrders AS (
    -- Count orders with 'DELIVERED' status for the top store
    SELECT COUNT(d."delivery_status") AS delivered_orders
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    JOIN "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" d
    ON o."delivery_order_id" = d."delivery_order_id"
    WHERE o."store_id" = (SELECT "store_id" FROM TopStore)
    AND d."delivery_status" = 'DELIVERED'
)
-- Calculate the ratio of 'DELIVERED' orders to total orders for the top store
SELECT 
    (SELECT delivered_orders FROM DeliveredOrders) / (SELECT total_orders FROM TotalOrders) AS delivered_to_total_ratio;