SELECT u."email", avg_order."avg_order_value"
FROM (
    -- Calculate average order value for users who registered and purchased in 2019
    SELECT t1."user_id", t1."total_order_value" / t2."total_orders" AS "avg_order_value"
    FROM (
        -- Calculate total order value per user
        SELECT oi."user_id", SUM(oi."sale_price" * o."num_of_item") AS "total_order_value"
        FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
        JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
        ON oi."order_id" = o."order_id"
        WHERE o."status" = 'Complete' 
        AND o."created_at" >= 1546300800000000 AND o."created_at" < 1577836800000000
        GROUP BY oi."user_id"
    ) t1
    JOIN (
        -- Count the number of completed orders per user
        SELECT "user_id", COUNT("order_id") AS "total_orders"
        FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS"
        WHERE "created_at" >= 1546300800000000 AND "created_at" < 1577836800000000
        AND "status" = 'Complete'
        GROUP BY "user_id"
    ) t2
    ON t1."user_id" = t2."user_id"
) avg_order
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u
ON avg_order."user_id" = u."id"
WHERE u."created_at" >= 1546300800000000 AND u."created_at" < 1577836800000000
ORDER BY avg_order."avg_order_value" DESC NULLS LAST
LIMIT 10;