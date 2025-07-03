SELECT 
    (CAST(
        (SELECT COUNT(*) 
         FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f 
         INNER JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c 
         ON f."id" = c."id" 
         WHERE f."repo_name" IN (
             SELECT DISTINCT l."repo_name" 
             FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l 
             WHERE l."language" NOT ILIKE '%python%') 
         AND f."path" ILIKE '%readme.md%' 
         AND c."content" ILIKE '%Copyright (c)%') 
        AS FLOAT) 
    / 
    (SELECT COUNT(*) 
     FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES 
     WHERE "repo_name" IN (
         SELECT DISTINCT "repo_name" 
         FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES 
         WHERE "language" NOT ILIKE '%python%') 
     AND "path" ILIKE '%readme.md%')) 
AS "proportion";