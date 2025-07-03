SELECT 
  COUNT(DISTINCT f."id")::FLOAT / NULLIF((SELECT COUNT(f."id") 
                                          FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
                                          JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
                                          ON f."repo_name" = l."repo_name"
                                          WHERE f."path" ILIKE '%readme.md%' 
                                          AND l."language"::STRING ILIKE '%python%' = FALSE), 0) AS "proportion"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
ON f."id" = c."id"
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
ON f."repo_name" = l."repo_name"
WHERE f."path" ILIKE '%readme.md%' 
AND c."content" ILIKE '%Copyright (c)%' 
AND l."language"::STRING ILIKE '%python%' = FALSE;