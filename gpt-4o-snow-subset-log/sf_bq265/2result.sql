SELECT u."email", avg_orders."avg_order_value"
FROM (
  SELECT "user_id", 
         SUM("order_value") / COUNT("order_id") AS "avg_order_value"
  FROM (
    SELECT o."user_id", 
           o."order_id", 
           (o."num_of_item" * i."sale_price") AS "order_value"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" i
    ON o."order_id" = i."order_id"
    WHERE o."created_at" >= 1546300800000000 
      AND o."created_at" < 1577836800000000
  ) subquery
  GROUP BY "user_id"
) avg_orders
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u
ON avg_orders."user_id" = u."id"
WHERE u."created_at" >= 1546300800000000 
  AND u."created_at" < 1577836800000000
ORDER BY avg_orders."avg_order_value" DESC NULLS LAST
LIMIT 10;