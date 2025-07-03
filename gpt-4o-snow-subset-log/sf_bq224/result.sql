SELECT 
    r."repo_name", 
    r."watch_count" AS total_watch_count,
    l."license"
FROM 
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS r
INNER JOIN 
    GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES l 
ON 
    r."repo_name" = l."repo_name"
WHERE 
    l."license" IN ('mit', 'bsd-2-clause', 'bsd-3-clause', 'apache-2.0', 'epl-1.0') -- Replace with approved licenses from `licenses.md`
ORDER BY 
    r."watch_count" DESC NULLS LAST
LIMIT 1;