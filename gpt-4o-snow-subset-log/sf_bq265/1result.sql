SELECT u."email"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
ON u."id" = o."user_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
ON o."order_id" = oi."order_id"
WHERE u."created_at" >= 1546300800000000 AND u."created_at" < 1577836800000000 -- Users who registered in 2019
  AND o."created_at" >= 1546300800000000 AND o."created_at" < 1577836800000000 -- Orders in 2019
  AND oi."created_at" >= 1546300800000000 AND oi."created_at" < 1577836800000000 -- Order items in 2019
GROUP BY u."email"
ORDER BY AVG(oi."sale_price" * o."num_of_item") DESC NULLS LAST
LIMIT 10;