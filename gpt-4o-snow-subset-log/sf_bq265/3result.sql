WITH user_registration_2019 AS (
    SELECT "id", "email"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
    WHERE "created_at" BETWEEN 1546300800000000 AND 1577836800000000
),
orders_2019 AS (
    SELECT o."user_id", 
           o."order_id", 
           o."num_of_item", 
           i."sale_price"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS i
      ON o."order_id" = i."order_id"
    WHERE o."created_at" BETWEEN 1546300800000000 AND 1577836800000000
      AND o."status" NOT ILIKE '%Cancelled%'
),
user_avg_order_value_2019 AS (
    SELECT o."user_id",
           (SUM(o."num_of_item" * o."sale_price") / COUNT(o."order_id")) AS "avg_order_value"
    FROM orders_2019 o
    GROUP BY o."user_id"
),
top_users_2019 AS (
    SELECT u."user_id", u."avg_order_value"
    FROM user_avg_order_value_2019 u
    JOIN user_registration_2019 r
      ON u."user_id" = r."id"
    ORDER BY u."avg_order_value" DESC NULLS LAST
    LIMIT 10
)
SELECT r."email" AS "User Email", 
       t."avg_order_value" AS "Average Order Value"
FROM top_users_2019 t
JOIN user_registration_2019 r
  ON t."user_id" = r."id";