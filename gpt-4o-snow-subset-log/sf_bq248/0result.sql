SELECT 
    COUNT(DISTINCT f."id")::FLOAT / 
    (SELECT COUNT(DISTINCT f."id") 
     FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
     JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
     ON f."id" = c."id"
     JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
     ON f."repo_name" = l."repo_name"
     WHERE l."language" NOT ILIKE '%python%' AND f."path" ILIKE '%readme.md%') 
    AS "proportion"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
ON f."id" = c."id"
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
ON f."repo_name" = l."repo_name"
WHERE l."language" NOT ILIKE '%python%' AND f."path" ILIKE '%readme.md%' AND c."content" ILIKE '%Copyright (c)%';