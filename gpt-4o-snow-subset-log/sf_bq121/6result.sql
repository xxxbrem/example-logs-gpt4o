SELECT years."membership_years", 
       AVG(u."reputation") AS "avg_reputation", 
       COALESCE(AVG(badge_counts."badge_count"), 0) AS "avg_badge_count"
FROM (
    SELECT "id", 
           FLOOR(("last_access_date" - "creation_date") / (1000000 * 86400 * 365)) AS "membership_years"
    FROM STACKOVERFLOW.STACKOVERFLOW.USERS
    WHERE "creation_date" <= 1633046400000000
) AS years
JOIN STACKOVERFLOW.STACKOVERFLOW.USERS u ON years."id" = u."id"
LEFT JOIN (
    SELECT b."user_id", COUNT(b."id") AS "badge_count"
    FROM STACKOVERFLOW.STACKOVERFLOW.BADGES b
    GROUP BY b."user_id"
) AS badge_counts ON u."id" = badge_counts."user_id"
GROUP BY years."membership_years"
ORDER BY years."membership_years" ASC NULLS LAST;