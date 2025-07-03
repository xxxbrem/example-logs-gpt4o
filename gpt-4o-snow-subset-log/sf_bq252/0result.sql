SELECT "sample_repo_name" 
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" 
WHERE "copies" = (
    SELECT MAX("copies") 
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" 
    WHERE "binary" = False AND "sample_path" ILIKE '%.swift%'
)
AND "binary" = False AND "sample_path" ILIKE '%.swift%'
LIMIT 1;