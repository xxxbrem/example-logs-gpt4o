SELECT 
  TO_CHAR(TO_TIMESTAMP(o."created_at" / 1000000), 'YYYY-MM') AS "month",
  u."country",
  p."department",
  p."category",
  COUNT(DISTINCT o."order_id") AS "number_of_orders",
  COUNT(DISTINCT o."user_id") AS "number_of_unique_purchasers",
  SUM(p."retail_price") - SUM(p."cost") AS "profit"
FROM (
  -- Subquery to extract users who registered in 2021
  SELECT DISTINCT "id" AS "user_id", "country" 
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS 
  WHERE "created_at" >= 1609459200000000 -- January 1, 2021 (microseconds)
    AND "created_at" < 1640995200000000 -- January 1, 2022 (microseconds)
) u
JOIN (
  -- Subquery to extract orders placed in 2021
  SELECT DISTINCT "order_id", "user_id", "created_at" 
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS 
  WHERE "created_at" >= 1609459200000000 -- January 1, 2021 (microseconds)
    AND "created_at" < 1640995200000000 -- January 1, 2022 (microseconds)
) o
ON u."user_id" = o."user_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
ON o."order_id" = oi."order_id"
JOIN (
  -- Subquery to extract inventory items created in 2021
  SELECT DISTINCT "id" AS "inventory_item_id", "product_id" 
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.INVENTORY_ITEMS 
  WHERE "created_at" >= 1609459200000000 -- January 1, 2021 (microseconds)
    AND "created_at" < 1640995200000000 -- January 1, 2022 (microseconds)
) ii
ON oi."inventory_item_id" = ii."inventory_item_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
ON ii."product_id" = p."id"
GROUP BY "month", u."country", p."department", p."category"
ORDER BY "month"
LIMIT 20;