SELECT sr."repo_name", SUM(sr."watch_count") AS "total_watch_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_REPOS" sr
WHERE sr."repo_name" IN (
  SELECT DISTINCT f."repo_name"
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
  JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
    ON c."id" = f."id"
  WHERE f."path" ILIKE '%.py%'
    AND c."size" < 15000
    AND c."content" ILIKE '%def %'
)
GROUP BY sr."repo_name"
ORDER BY "total_watch_count" DESC NULLS LAST
LIMIT 3;