SELECT 
    "gender", 
    COUNT(CASE WHEN "age" = (SELECT MIN("age") 
                             FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                             WHERE "created_at" >= 1546300800000000 
                               AND "created_at" <= 1651363200000000) THEN 1 ELSE NULL END) AS "youngest_user_count",
    COUNT(CASE WHEN "age" = (SELECT MAX("age") 
                             FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
                             WHERE "created_at" >= 1546300800000000 
                               AND "created_at" <= 1651363200000000) THEN 1 ELSE NULL END) AS "oldest_user_count"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
WHERE "created_at" >= 1546300800000000 
  AND "created_at" <= 1651363200000000
GROUP BY "gender";