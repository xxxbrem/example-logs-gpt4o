SELECT "gender", 
       SUM(CASE WHEN "age" = (SELECT MIN("age") 
                              FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                              WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000) 
                THEN 1 ELSE 0 END) AS "total_youngest_users",
       SUM(CASE WHEN "age" = (SELECT MAX("age") 
                              FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" 
                              WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000) 
                THEN 1 ELSE 0 END) AS "total_oldest_users"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000
GROUP BY "gender";