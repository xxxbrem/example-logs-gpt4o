SELECT 
    DATE_PART('MONTH', TO_TIMESTAMP(o."created_at" / 1000000)) AS "month",
    COUNT(DISTINCT o."order_id") AS "num_orders",
    COUNT(DISTINCT o."user_id") AS "unique_purchasers",
    SUM(ii."product_retail_price" - ii."cost") AS "profit",
    u."country",
    p."department",
    p."category"
FROM 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi ON o."order_id" = oi."order_id"
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.INVENTORY_ITEMS ii ON oi."inventory_item_id" = ii."id"
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u ON o."user_id" = u."id"
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p ON ii."product_id" = p."id"
WHERE 
    o."created_at" BETWEEN 1609459200000000 AND 1640995199000000 -- Orders placed in 2021
    AND ii."created_at" BETWEEN 1609459200000000 AND 1640995199000000 -- Inventory items created in 2021
    AND u."created_at" BETWEEN 1609459200000000 AND 1640995199000000 -- Users registered in 2021
GROUP BY 
    DATE_PART('MONTH', TO_TIMESTAMP(o."created_at" / 1000000)),
    u."country",
    p."department",
    p."category"
ORDER BY 
    "month", 
    "country", 
    "department", 
    "category";