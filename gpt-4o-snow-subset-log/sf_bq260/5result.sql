SELECT 
    "gender", 
    SUM(CASE WHEN "age" = (SELECT MIN("age") FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS 
                      WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
             THEN 1 ELSE 0 END) AS "youngest_users_count",
    SUM(CASE WHEN "age" = (SELECT MAX("age") FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS 
                      WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000) 
             THEN 1 ELSE 0 END) AS "oldest_users_count"
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS 
WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000
GROUP BY "gender";