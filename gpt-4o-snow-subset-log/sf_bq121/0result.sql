SELECT 
    FLOOR((DATE_PART(EPOCH_SECOND, TIMESTAMP '2021-10-01 00:00:00') * 1000000 - u."creation_date") / 1000000 / 31536000) AS "years_membership",
    AVG(u."reputation") AS "avg_reputation",
    AVG(COUNT(b."id")) OVER (PARTITION BY FLOOR((DATE_PART(EPOCH_SECOND, TIMESTAMP '2021-10-01 00:00:00') * 1000000 - u."creation_date") / 1000000 / 31536000)) AS "avg_badges"
FROM 
    "STACKOVERFLOW"."STACKOVERFLOW"."USERS" u
LEFT JOIN 
    "STACKOVERFLOW"."STACKOVERFLOW"."BADGES" b
    ON u."id" = b."user_id"
WHERE 
    u."creation_date" <= DATE_PART(EPOCH_SECOND, TIMESTAMP '2021-10-01 00:00:00') * 1000000
GROUP BY 
    1, u."id"
ORDER BY 
    "years_membership" ASC
LIMIT 20;