WITH UserMembershipYears AS (
    SELECT 
        "id" AS "user_id",
        (2021 - EXTRACT(YEAR FROM DATEADD(SECOND, "creation_date" / 1000000, TIMESTAMP '1970-01-01 00:00:00'))) AS "complete_years",
        "reputation"
    FROM STACKOVERFLOW.STACKOVERFLOW.USERS
    WHERE "creation_date" <= 1633046400000000 -- Users created on or before October 1, 2021
),
UserBadgeCounts AS (
    SELECT 
        "user_id",
        COUNT("id") AS "badge_count"
    FROM STACKOVERFLOW.STACKOVERFLOW.BADGES
    GROUP BY "user_id"
),
CombinedData AS (
    SELECT 
        u."complete_years",
        u."reputation",
        COALESCE(b."badge_count", 0) AS "badge_count"
    FROM UserMembershipYears u
    LEFT JOIN UserBadgeCounts b ON u."user_id" = b."user_id"
)
SELECT 
    "complete_years",
    AVG("reputation") AS "average_reputation",
    AVG("badge_count") AS "average_badges"
FROM CombinedData
GROUP BY "complete_years"
ORDER BY "complete_years";