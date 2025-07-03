SELECT 
    DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."created_at" / 1e6)) AS "month",
    SUM(oi."sale_price") AS "total_sales",
    SUM(p."cost") AS "total_cost",
    COUNT(DISTINCT oi."order_id") AS "completed_orders",
    SUM(oi."sale_price") - SUM(p."cost") AS "total_profit",
    CASE 
        WHEN SUM(p."cost") = 0 THEN NULL
        ELSE (SUM(oi."sale_price") - SUM(p."cost")) / SUM(p."cost")
    END AS "profit_to_cost_ratio"
FROM 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS oi
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" AS p
ON 
    oi."product_id" = p."id"
WHERE 
    oi."status" = 'Complete'
    AND p."category" ILIKE '%Sleep%Lounge%'
    AND oi."created_at" >= 1672531200000000 -- January 1, 2023 in microseconds
    AND oi."created_at" < 1704067200000000  -- January 1, 2024 in microseconds
GROUP BY 
    DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."created_at" / 1e6))
ORDER BY 
    "month"
LIMIT 20;