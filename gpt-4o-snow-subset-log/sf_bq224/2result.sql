SELECT 
    sr."repo_name", 
    l."license", 
    sr."watch_count" AS "total_activity"
FROM 
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS sr
JOIN 
    GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES l
ON 
    sr."repo_name" = l."repo_name"
WHERE 
    l."license" IN ('epl-1.0', 'mit', 'apache-2.0', 'gpl-3.0') -- Example approved licenses from licenses.md
ORDER BY 
    "total_activity" DESC NULLS LAST
LIMIT 1;