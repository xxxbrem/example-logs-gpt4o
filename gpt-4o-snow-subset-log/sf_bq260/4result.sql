SELECT 
    "gender", 
    CASE 
        WHEN "age" = ( 
            SELECT MIN("age") 
            FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
            WHERE 
                "created_at" >= 1546300800000000 -- January 1, 2019
                AND "created_at" <= 1651363200000000 -- April 30, 2022
        ) THEN 'youngest'
        WHEN "age" = ( 
            SELECT MAX("age") 
            FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
            WHERE 
                "created_at" >= 1546300800000000 -- January 1, 2019
                AND "created_at" <= 1651363200000000 -- April 30, 2022
        ) THEN 'oldest'
    END AS "age_category",
    COUNT(*) AS "user_count"
FROM 
    "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
WHERE 
    "created_at" >= 1546300800000000 -- January 1, 2019
    AND "created_at" <= 1651363200000000 -- April 30, 2022
    AND (
        "age" = ( 
            SELECT MIN("age") 
            FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
            WHERE 
                "created_at" >= 1546300800000000 
                AND "created_at" <= 1651363200000000 
        ) 
        OR 
        "age" = ( 
            SELECT MAX("age") 
            FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
            WHERE 
                "created_at" >= 1546300800000000 
                AND "created_at" <= 1651363200000000 
        )
    )
GROUP BY 
    "gender", 
    "age_category";