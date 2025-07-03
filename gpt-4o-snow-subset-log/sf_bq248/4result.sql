SELECT 
  (CAST((
    SELECT COUNT(DISTINCT c."id")
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
    JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
    ON c."id" = f."id"
    JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
    ON f."repo_name" = l."repo_name"
    WHERE l."language" NOT ILIKE '%python%'
    AND f."path" ILIKE '%readme.md%'
    AND c."content" ILIKE '%Copyright (c)%'
  ) AS FLOAT) /
  (SELECT COUNT(*)
   FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
   JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l 
   ON f."repo_name" = l."repo_name"
   WHERE l."language" NOT ILIKE '%python%'
   AND f."path" ILIKE '%readme.md%')) AS "proportion";