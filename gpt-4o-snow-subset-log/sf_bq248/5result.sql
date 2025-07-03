SELECT 
    COUNT(DISTINCT sc."id") * 1.0 / COUNT(DISTINCT sf."id") AS "proportion_of_readme_with_copyright"
FROM 
    "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc
JOIN 
    "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf
ON 
    sc."id" = sf."id"
WHERE 
    sf."path" ILIKE '%readme.md%'
    AND sc."sample_path" ILIKE '%readme.md%' 
    AND sc."content" ILIKE '%Copyright (c)%'
    AND sf."repo_name" IN (
        SELECT DISTINCT "repo_name" 
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" 
        WHERE "language" ILIKE '%python%' = FALSE
    );