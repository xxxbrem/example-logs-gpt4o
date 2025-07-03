SELECT 
    TO_CHAR(TO_TIMESTAMP(t2."created_at" / 1000000), 'YYYY-MM') AS "order_month",
    t3."country",
    t1."product_department",
    t1."product_category",
    COUNT(DISTINCT t2."order_id") AS "num_orders",
    COUNT(DISTINCT t2."user_id") AS "num_unique_purchasers",
    SUM(t4."retail_price") - SUM(t1."cost") AS "profit"
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.INVENTORY_ITEMS t1
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS t2
ON t1."id" = t2."inventory_item_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS t3
ON t2."user_id" = t3."id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS t4
ON t1."product_id" = t4."id"
WHERE t2."created_at" >= 1609459200000000 
  AND t2."created_at" < 1640995200000000
  AND t1."created_at" >= 1609459200000000 
  AND t1."created_at" < 1640995200000000
  AND t3."created_at" >= 1609459200000000 
  AND t3."created_at" < 1640995200000000
GROUP BY 
    TO_CHAR(TO_TIMESTAMP(t2."created_at" / 1000000), 'YYYY-MM'), 
    t3."country", 
    t1."product_department", 
    t1."product_category"
ORDER BY "order_month" ASC, "num_orders" DESC NULLS LAST;