WITH youngest_ages AS (
    SELECT 
        "gender", 
        MIN("age") AS "youngest_age"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000
    GROUP BY "gender"
),
oldest_ages AS (
    SELECT 
        "gender", 
        MAX("age") AS "oldest_age"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
    WHERE "created_at" >= 1546300800000000 AND "created_at" <= 1651363200000000
    GROUP BY "gender"
)
SELECT 
    u."gender", 
    'Youngest' AS "category", 
    COUNT(*) AS "user_count"
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
JOIN youngest_ages y
  ON u."gender" = y."gender" AND u."age" = y."youngest_age"
WHERE u."created_at" >= 1546300800000000 AND u."created_at" <= 1651363200000000
GROUP BY u."gender"

UNION ALL

SELECT 
    u."gender", 
    'Oldest' AS "category", 
    COUNT(*) AS "user_count"
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
JOIN oldest_ages o
  ON u."gender" = o."gender" AND u."age" = o."oldest_age"
WHERE u."created_at" >= 1546300800000000 AND u."created_at" <= 1651363200000000
GROUP BY u."gender";