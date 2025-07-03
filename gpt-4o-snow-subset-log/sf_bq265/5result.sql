SELECT 
    U."email", 
    OI."user_id", 
    AVG(O."num_of_item" * OI."sale_price") AS "average_order_value"
FROM 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS U
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS O
ON 
    U."id" = O."user_id"
INNER JOIN 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS OI
ON 
    O."order_id" = OI."order_id"
WHERE 
    U."created_at" >= 1546300800000000 AND U."created_at" < 1577836800000000 -- Users registered in 2019
    AND O."created_at" >= 1546300800000000 AND O."created_at" < 1577836800000000 -- Orders placed in 2019
    AND OI."created_at" >= 1546300800000000 AND OI."created_at" < 1577836800000000 -- Order items created in 2019
GROUP BY 
    OI."user_id", U."email"
ORDER BY 
    AVG(O."num_of_item" * OI."sale_price") DESC NULLS LAST
LIMIT 10;