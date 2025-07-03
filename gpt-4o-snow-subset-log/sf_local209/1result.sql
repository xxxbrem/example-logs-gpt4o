WITH STORE_ORDER_COUNT AS (
    SELECT 
        "ORDERS"."store_id",
        "STORES"."store_name",
        COUNT("ORDERS"."order_id") AS "total_orders"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" AS "ORDERS"
    JOIN 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" AS "STORES"
    ON 
        "ORDERS"."store_id" = "STORES"."store_id"
    GROUP BY 
        "ORDERS"."store_id", "STORES"."store_name"
    ORDER BY 
        "total_orders" DESC NULLS LAST
    LIMIT 1
),
DELIVERED_ORDER_COUNT AS (
    SELECT 
        "ORDERS"."store_id",
        COUNT("ORDERS"."order_id") AS "delivered_orders"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" AS "ORDERS"
    LEFT JOIN 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" AS "DELIVERIES"
    ON 
        "ORDERS"."delivery_order_id" = "DELIVERIES"."delivery_order_id"
    WHERE 
        "DELIVERIES"."delivery_status" = 'DELIVERED'
    GROUP BY 
        "ORDERS"."store_id"
)
SELECT 
    SOC."store_name",
    SOC."store_id",
    SOC."total_orders",
    COALESCE(DOC."delivered_orders", 0) AS "delivered_orders",
    COALESCE(DOC."delivered_orders", 0)::FLOAT / GREATEST(SOC."total_orders", 1) AS "delivered_order_ratio"
FROM 
    STORE_ORDER_COUNT AS SOC
LEFT JOIN 
    DELIVERED_ORDER_COUNT AS DOC
ON 
    SOC."store_id" = DOC."store_id";