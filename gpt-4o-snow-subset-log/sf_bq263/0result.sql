SELECT 
    TO_CHAR(TO_TIMESTAMP(o."created_at" / 1000000), 'YYYY-MM') AS "month", 
    SUM(oi."sale_price") AS "total_sales", 
    SUM(ii."cost") AS "total_cost", 
    COUNT(DISTINCT o."order_id") AS "completed_order_count", 
    SUM(oi."sale_price" - ii."cost") AS "total_profit", 
    ROUND(SUM(oi."sale_price" - ii."cost") / NULLIF(SUM(ii."cost"), 0), 4) AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    ON o."order_id" = oi."order_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii
    ON oi."inventory_item_id" = ii."id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p
    ON ii."product_id" = p."id"
WHERE o."status" = 'Complete'
  AND o."created_at" BETWEEN 1672531200000000 AND 1704067199000000 -- January 1, 2023, to December 31, 2023
  AND p."category" = 'Sleep & Lounge'
GROUP BY "month"
ORDER BY "month";