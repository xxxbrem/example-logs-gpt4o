SELECT 
    l."repo_name", 
    l."license", 
    SUM(r."watch_count") AS total_activity
FROM 
    GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES l
JOIN 
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS r
ON 
    l."repo_name" = r."repo_name"
GROUP BY 
    l."repo_name", l."license"
ORDER BY 
    total_activity DESC NULLS LAST
LIMIT 1;