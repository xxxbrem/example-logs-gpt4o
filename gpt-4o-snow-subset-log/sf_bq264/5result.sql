SELECT ABS(
    (SELECT COUNT(*) 
     FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
     WHERE "age" = (SELECT MAX("age") 
                    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651276799999999))
    -
    (SELECT COUNT(*) 
     FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
     WHERE "age" = (SELECT MIN("age") 
                    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651276799999999))
) AS "difference_in_users";