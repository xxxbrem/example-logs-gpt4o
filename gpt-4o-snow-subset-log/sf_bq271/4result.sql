SELECT 
    TO_CHAR(TO_TIMESTAMP(o."created_at"/1000000), 'YYYY-MM') AS "order_month",
    u."country",
    p."department" AS "product_department",
    p."category" AS "product_category",
    COUNT(DISTINCT o."order_id") AS "number_of_orders",
    COUNT(DISTINCT o."user_id") AS "number_of_unique_purchasers",
    SUM(p."retail_price") - SUM(p."cost") AS "profit"
FROM 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi 
ON 
    o."order_id" = oi."order_id"
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u 
ON 
    o."user_id" = u."id"
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p 
ON 
    oi."product_id" = p."id"
WHERE 
    o."created_at" >= 1609459200000000 AND o."created_at" < 1640995200000000 -- Orders placed in 2021
    AND u."created_at" >= 1609459200000000 AND u."created_at" < 1640995200000000 -- Users registered in 2021
    AND p."id" IN (
        SELECT 
            DISTINCT "product_id" 
        FROM 
            "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS"
        WHERE 
            "created_at" >= 1609459200000000 AND "created_at" < 1640995200000000 -- Inventory items created in 2021
    )
GROUP BY 
    TO_CHAR(TO_TIMESTAMP(o."created_at"/1000000), 'YYYY-MM'),
    u."country",
    p."department",
    p."category"
ORDER BY 
    "order_month" ASC,
    "country" ASC,
    "product_department" ASC,
    "product_category" ASC
LIMIT 100;