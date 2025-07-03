SELECT sr."repo_name", SUM(sr."watch_count") AS "total_watch_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_REPOS" sr 
JOIN (
    SELECT DISTINCT sf."repo_name" 
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf 
    JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc 
    ON sf."id" = sc."id" 
    WHERE sc."sample_path" ILIKE '%.py%' 
    AND sc."content" ILIKE '%def %' 
    AND sc."size" < 15000
) filtered_repos 
ON sr."repo_name" = filtered_repos."repo_name" 
GROUP BY sr."repo_name" 
ORDER BY "total_watch_count" DESC NULLS LAST 
LIMIT 3;