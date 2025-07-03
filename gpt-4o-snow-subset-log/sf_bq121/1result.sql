SELECT 
  FLOOR(DATEDIFF(YEAR, DATEADD(MICROSECOND, derived."creation_date", '1970-01-01'), '2023-10-01')) AS "complete_years",
  AVG(derived."reputation") AS "avg_reputation", 
  AVG(derived."badge_count") AS "avg_badge_count"
FROM (
  SELECT 
    u."id" AS "user_id",
    u."reputation",
    COUNT(b."id") AS "badge_count",
    u."creation_date"
  FROM 
    "STACKOVERFLOW"."STACKOVERFLOW"."USERS" u
  LEFT JOIN 
    "STACKOVERFLOW"."STACKOVERFLOW"."BADGES" b
  ON 
    u."id" = b."user_id"
  WHERE 
    DATEADD(MICROSECOND, u."creation_date", '1970-01-01') <= '2021-10-01'
  GROUP BY 
    u."id", u."reputation", u."creation_date"
) derived
GROUP BY FLOOR(DATEDIFF(YEAR, DATEADD(MICROSECOND, derived."creation_date", '1970-01-01'), '2023-10-01'))
ORDER BY "complete_years" DESC
LIMIT 20;