SELECT 
    licenses."repo_name", 
    licenses."license", 
    repos."watch_count" AS "total_activity"
FROM 
    GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES licenses
JOIN 
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS repos
ON 
    licenses."repo_name" = repos."repo_name"
WHERE 
    licenses."license" IN ('mit', 'apache-2.0', 'gpl-2.0', 'gpl-3.0', 'bsd-3-clause', 'bsd-2-clause', 'unlicense', 'agpl-3.0', 'lgpl-3.0', 'cc0-1.0', 'epl-1.0', 'lgpl-2.1', 'mpl-2.0', 'isc', 'artistic-2.0')
ORDER BY 
    "total_activity" DESC NULLS LAST
LIMIT 1;