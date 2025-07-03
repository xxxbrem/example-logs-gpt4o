SELECT 
    EXTRACT(MONTH FROM TO_TIMESTAMP(o."created_at" / 1000000)) AS "order_month",
    u."country",
    ii."product_department",
    ii."product_category",
    COUNT(DISTINCT o."order_id") AS "num_of_orders",
    COUNT(DISTINCT u."id") AS "num_of_unique_purchasers",
    SUM(p."retail_price" - p."cost") AS "profit"
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
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii
ON 
    oi."inventory_item_id" = ii."id"
JOIN 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p
ON 
    ii."product_id" = p."id"
WHERE 
    u."created_at" BETWEEN 1609459200000000 AND 1640995200000000 AND -- Users who registered in 2021
    ii."created_at" BETWEEN 1609459200000000 AND 1640995200000000 AND -- Inventory items created in 2021
    o."created_at" BETWEEN 1609459200000000 AND 1640995200000000 -- Orders placed in 2021
GROUP BY 
    u."country", ii."product_department", ii."product_category", "order_month"
ORDER BY 
    "order_month", u."country", ii."product_department", ii."product_category"
LIMIT 100;