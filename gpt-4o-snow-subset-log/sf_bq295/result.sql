SELECT r."repo_name", SUM(r."watch_count") AS "total_watch_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_REPOS" r
WHERE r."repo_name" IN (
  SELECT DISTINCT f."repo_name"
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
  JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
    ON f."id" = c."id"
  WHERE f."path" ILIKE '%.py%'
    AND c."size" < 15000
    AND c."content" ILIKE '%def %'
)
GROUP BY r."repo_name"
ORDER BY "total_watch_count" DESC NULLS LAST
LIMIT 3;