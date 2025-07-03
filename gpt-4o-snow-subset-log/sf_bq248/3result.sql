SELECT 
    (SELECT COUNT(DISTINCT f."id")
     FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f
     JOIN (
         SELECT DISTINCT "repo_name"
         FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES
         WHERE "language" NOT ILIKE '%python%'
     ) l
     ON f."repo_name" = l."repo_name"
     JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
     ON f."id" = c."id"
     WHERE f."path" ILIKE '%readme.md%' AND c."content" ILIKE '%copyright (c)%')::FLOAT
    /
    (SELECT COUNT(DISTINCT f."id")
     FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f
     JOIN (
         SELECT DISTINCT "repo_name"
         FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES
         WHERE "language" NOT ILIKE '%python%'
     ) l
     ON f."repo_name" = l."repo_name"
     WHERE f."path" ILIKE '%readme.md%')::FLOAT AS "proportion";