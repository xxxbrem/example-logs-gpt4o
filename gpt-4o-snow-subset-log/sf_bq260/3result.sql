SELECT 
    "gender", 
    'youngest' AS "age_category", 
    COUNT(*) AS "user_count"
FROM 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
WHERE 
    "created_at" >= 1546300800000000 
    AND "created_at" <= 1651363199000000
    AND "age" = (
        SELECT MIN("age") 
        FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
        WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000
    )
GROUP BY "gender"

UNION ALL

SELECT 
    "gender", 
    'oldest' AS "age_category", 
    COUNT(*) AS "user_count"
FROM 
    THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
WHERE 
    "created_at" >= 1546300800000000 
    AND "created_at" <= 1651363199000000
    AND "age" = (
        SELECT MAX("age") 
        FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
        WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363199000000
    )
GROUP BY "gender";