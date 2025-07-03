SELECT 
    (SELECT COUNT(*) 
     FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
     WHERE "age" = (SELECT MAX("age") 
                    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000)
     AND "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
    - 
    (SELECT COUNT(*) 
     FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
     WHERE "age" = (SELECT MIN("age") 
                    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000)
     AND "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
AS "count_difference";