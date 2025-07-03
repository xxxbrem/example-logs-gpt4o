WITH user_badge_counts AS (
    SELECT 
        u."id", 
        u."creation_date", 
        u."reputation", 
        COUNT(b."id") AS "badge_count"
    FROM STACKOVERFLOW.STACKOVERFLOW."USERS" u
    LEFT JOIN STACKOVERFLOW.STACKOVERFLOW."BADGES" b
    ON u."id" = b."user_id"
    WHERE u."creation_date" <= 1633046400000000 -- October 1, 2021, in microseconds
    GROUP BY u."id", u."creation_date", u."reputation"
)
SELECT 
    DATE_PART('YEAR', CURRENT_DATE) - DATE_PART('YEAR', TO_TIMESTAMP("creation_date" / 1000000)) AS "membership_years", 
    AVG("reputation") AS "average_reputation", 
    AVG("badge_count") AS "average_badges"
FROM user_badge_counts
GROUP BY DATE_PART('YEAR', CURRENT_DATE) - DATE_PART('YEAR', TO_TIMESTAMP("creation_date" / 1000000))
ORDER BY "membership_years"
LIMIT 20;