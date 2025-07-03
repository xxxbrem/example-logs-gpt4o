SELECT 
    (COUNT(CASE WHEN "age" = (SELECT MAX("age") 
                              FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                              WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
                THEN 1 END)
     -
     COUNT(CASE WHEN "age" = (SELECT MIN("age") 
                              FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                              WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
                THEN 1 END)
    ) AS "difference_oldest_youngest_user_count"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000;