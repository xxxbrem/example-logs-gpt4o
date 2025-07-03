WITH StoreOrderCount AS (
    SELECT 
        o."store_id", 
        COUNT(*) AS "total_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    GROUP BY o."store_id"
    ORDER BY "total_orders" DESC NULLS LAST
    LIMIT 1
),
DeliveredOrdersCount AS (
    SELECT 
        COUNT(*) AS "delivered_orders"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    LEFT JOIN DELIVERY_CENTER.DELIVERY_CENTER.DELIVERIES d
    ON o."delivery_order_id" = d."delivery_order_id"
    WHERE o."store_id" = (SELECT "store_id" FROM StoreOrderCount)
      AND d."delivery_status" = 'DELIVERED'
)
SELECT 
    (SELECT "store_id" FROM StoreOrderCount) AS "store_id_with_highest_orders",
    (SELECT "total_orders" FROM StoreOrderCount) AS "total_orders",
    (SELECT "delivered_orders" FROM DeliveredOrdersCount) AS "delivered_orders",
    ROUND((SELECT "delivered_orders" FROM DeliveredOrdersCount) / (SELECT "total_orders" FROM StoreOrderCount), 4) AS "delivered_to_total_ratio"
;