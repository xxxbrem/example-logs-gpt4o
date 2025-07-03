SELECT 
    TO_CHAR(TO_TIMESTAMP(oi."created_at" / 1000000), 'YYYY-MM') AS "month",
    SUM(oi."sale_price") AS "total_sales",
    SUM(p."cost") AS "total_cost",
    COUNT(DISTINCT oi."order_id") AS "number_of_complete_orders",
    SUM(oi."sale_price") - SUM(p."cost") AS "total_profit",
    (SUM(oi."sale_price") - SUM(p."cost")) / NULLIF(SUM(p."cost"), 0) AS "profit_to_cost_ratio"
FROM 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p
    ON oi."product_id" = p."id"
WHERE 
    p."category" = 'Sleep & Lounge'
    AND oi."status" = 'Complete'
    AND oi."created_at" >= 1672531200000000 -- January 1, 2023 in microseconds
    AND oi."created_at" < 1704067200000000  -- January 1, 2024 in microseconds
GROUP BY 
    "month"
ORDER BY 
    "month";