SELECT u."email", t1."avg_order_value"
FROM (
  SELECT t1."user_id", t1."total_value" / t2."total_orders" AS "avg_order_value"
  FROM (
    SELECT oi."user_id", SUM(oi."sale_price" * o."num_of_item") AS "total_value"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o 
      ON oi."order_id" = o."order_id"
    WHERE o."created_at" >= 1546300800000000 AND o."created_at" < 1577836800000000
    GROUP BY oi."user_id"
  ) t1
  JOIN (
    SELECT o."user_id", COUNT(DISTINCT o."order_id") AS "total_orders"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u
      ON o."user_id" = u."id"
    WHERE u."created_at" >= 1546300800000000 AND u."created_at" < 1577836800000000
      AND o."created_at" >= 1546300800000000 AND o."created_at" < 1577836800000000
    GROUP BY o."user_id"
  ) t2
  ON t1."user_id" = t2."user_id"
) t1
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u 
  ON t1."user_id" = u."id"
ORDER BY t1."avg_order_value" DESC NULLS LAST
LIMIT 10;