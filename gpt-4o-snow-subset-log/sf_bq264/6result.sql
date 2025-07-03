SELECT 
    ABS(
        (SELECT COUNT(*) 
         FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
         WHERE "created_at" >= 1546300800000000 
           AND "created_at" <= 1651363199000000
           AND "age" = (SELECT MAX("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                        WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000))
        - 
        (SELECT COUNT(*) 
         FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
         WHERE "created_at" >= 1546300800000000 
           AND "created_at" <= 1651363199000000
           AND "age" = (SELECT MIN("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                        WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000))
    ) AS "difference_in_user_count";