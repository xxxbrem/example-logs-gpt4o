SELECT 
    DATE_TRUNC('month', TO_TIMESTAMP("order_items"."created_at" / 1000000)) AS "order_month",
    SUM("order_items"."sale_price") AS "total_sales",
    SUM("inventory_items"."cost") AS "total_cost",
    COUNT(DISTINCT "order_items"."order_id") AS "number_of_complete_orders",
    SUM("order_items"."sale_price" - "inventory_items"."cost") AS "total_profit",
    (CASE 
        WHEN SUM("inventory_items"."cost") > 0 
        THEN SUM("order_items"."sale_price" - "inventory_items"."cost") / SUM("inventory_items"."cost") 
        ELSE 0 
    END) AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS "order_items"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" AS "inventory_items"
ON "order_items"."inventory_item_id" = "inventory_items"."id"
WHERE "inventory_items"."product_category" = 'Sleep & Lounge'
AND "order_items"."status" = 'Complete'
AND "order_items"."created_at" >= 1672531200000000 -- January 1, 2023, UTC in microseconds
AND "order_items"."created_at" < 1704067200000000  -- January 1, 2024, UTC in microseconds
GROUP BY "order_month"
ORDER BY "order_month"
LIMIT 12;