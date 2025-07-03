SELECT u."email", 
       t."average_order_value"
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
JOIN (
    SELECT o."user_id",
           SUM(o."num_of_item" * oi."sale_price") / COUNT(DISTINCT o."order_id") AS "average_order_value"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
      ON o."order_id" = oi."order_id"
    WHERE o."created_at" >= 1546300800000000
      AND o."created_at" < 1577836800000000
      AND oi."status" = 'Complete'
    GROUP BY o."user_id"
) t
  ON u."id" = t."user_id"
WHERE u."created_at" >= 1546300800000000
  AND u."created_at" < 1577836800000000
ORDER BY t."average_order_value" DESC NULLS LAST
LIMIT 10;