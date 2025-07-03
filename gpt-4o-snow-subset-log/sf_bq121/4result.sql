SELECT 
    FLOOR(DATEDIFF('YEAR', TO_TIMESTAMP(u."creation_date" / 1000000), CURRENT_DATE)) AS "membership_years",
    AVG(u."reputation") AS "avg_reputation",
    AVG(COUNT(b."id")) OVER (PARTITION BY FLOOR(DATEDIFF('YEAR', TO_TIMESTAMP(u."creation_date" / 1000000), CURRENT_DATE))) AS "avg_badge_count"
FROM "STACKOVERFLOW"."STACKOVERFLOW"."USERS" u
LEFT JOIN "STACKOVERFLOW"."STACKOVERFLOW"."BADGES" b 
ON u."id" = b."user_id"
WHERE u."creation_date" <= 1633046400000000
GROUP BY FLOOR(DATEDIFF('YEAR', TO_TIMESTAMP(u."creation_date" / 1000000), CURRENT_DATE))
ORDER BY "membership_years";