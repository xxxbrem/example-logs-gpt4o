SELECT FLOOR((1640995200000000 - u."creation_date") / 31536000000000) AS "full_years_membership", 
       AVG(u."reputation") AS "average_reputation", 
       AVG(b.badge_count) AS "average_badges" 
FROM "STACKOVERFLOW"."STACKOVERFLOW"."USERS" u 
LEFT JOIN (
    SELECT "user_id", COUNT("id") AS badge_count 
    FROM "STACKOVERFLOW"."STACKOVERFLOW"."BADGES" 
    GROUP BY "user_id"
) b 
ON u."id" = b."user_id" 
WHERE u."creation_date" <= 1633046400000000 
GROUP BY FLOOR((1640995200000000 - u."creation_date") / 31536000000000) 
ORDER BY "full_years_membership" ASC 
LIMIT 20;