SELECT "email"
FROM (
  SELECT u."id" AS "user_id", u."email", 
         SUM(o."num_of_item" * oi."sale_price") / COUNT(o."order_id") AS "average_order_value"
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS AS u
  JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS AS o
  ON u."id" = o."user_id"
  JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS AS oi
  ON o."order_id" = oi."order_id"
  WHERE u."created_at" >= 1546300800000000 AND u."created_at" < 1577836800000000
  AND o."created_at" >= 1546300800000000 AND o."created_at" < 1577836800000000
  AND oi."status" != 'Cancelled'
  GROUP BY u."id", u."email"
  ORDER BY "average_order_value" DESC NULLS LAST
  LIMIT 10
);