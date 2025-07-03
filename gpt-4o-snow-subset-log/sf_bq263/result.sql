SELECT 
    DATE_TRUNC('month', TO_TIMESTAMP(oi."created_at" / 1000000)) AS "month", 
    SUM(oi."sale_price") AS "total_sales", 
    SUM(ii."cost") AS "total_cost", 
    COUNT(DISTINCT oi."order_id") AS "complete_order_count", 
    SUM(oi."sale_price" - ii."cost") AS "total_profit", 
    SUM(oi."sale_price" - ii."cost") / NULLIF(SUM(ii."cost"), 0) AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi 
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii 
ON oi."inventory_item_id" = ii."id" 
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p 
ON ii."product_id" = p."id" 
WHERE oi."status" = 'Complete' 
AND oi."created_at" BETWEEN 1672531200000000 AND 1704067199000000 
AND p."category" = 'Sleep & Lounge' 
GROUP BY DATE_TRUNC('month', TO_TIMESTAMP(oi."created_at" / 1000000)) 
ORDER BY "month";