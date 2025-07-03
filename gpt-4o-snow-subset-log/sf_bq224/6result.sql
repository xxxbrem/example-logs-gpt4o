SELECT 
    r."repo_name",
    r."watch_count" AS total_activity
FROM GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES l
JOIN GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS r
    ON l."repo_name" = r."repo_name"
WHERE l."license" ILIKE '%MIT%'
   OR l."license" ILIKE '%BSD%'
   OR l."license" ILIKE '%Apache%'
ORDER BY total_activity DESC NULLS LAST
LIMIT 1;