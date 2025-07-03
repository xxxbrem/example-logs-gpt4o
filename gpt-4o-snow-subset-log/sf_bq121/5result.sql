SELECT 
  FLOOR((1633046400000000 - u."creation_date") / (1000000 * 60 * 60 * 24 * 365)) AS "years_since_registration",
  AVG(u."reputation") AS "avg_reputation",
  COUNT(b."id") AS "total_badges",
  COUNT(DISTINCT u."id") AS "users_count"
FROM STACKOVERFLOW.STACKOVERFLOW.USERS u
LEFT JOIN STACKOVERFLOW.STACKOVERFLOW.BADGES b
ON u."id" = b."user_id"
WHERE u."creation_date" <= 1633046400000000 -- October 1, 2021
  AND u."reputation" > 0
GROUP BY FLOOR((1633046400000000 - u."creation_date") / (1000000 * 60 * 60 * 24 * 365))
ORDER BY "years_since_registration";