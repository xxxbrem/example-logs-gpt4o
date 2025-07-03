SELECT 
    TO_CHAR(TO_TIMESTAMP(oi."created_at" / 1000000), 'YYYY-MM') AS "month",
    SUM(oi."sale_price") AS "total_sales",
    SUM(ii."cost") AS "total_cost",
    COUNT(DISTINCT oi."order_id") AS "completed_orders",
    SUM(oi."sale_price") - SUM(ii."cost") AS "total_profit",
    (SUM(oi."sale_price") - SUM(ii."cost")) / NULLIF(SUM(ii."cost"), 0) AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii
ON oi."inventory_item_id" = ii."id"
WHERE oi."status" = 'Complete'
AND oi."created_at" BETWEEN 1672531200000000 AND 1704067199000000
AND ii."product_id" IN (
    SELECT "id"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS"
    WHERE "category" ILIKE '%Sleep%Lounge%'
)
GROUP BY "month"
ORDER BY "month";