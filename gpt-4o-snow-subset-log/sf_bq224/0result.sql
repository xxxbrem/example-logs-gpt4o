SELECT 
    repos."repo_name", 
    repos."watch_count", 
    licenses."license"
FROM GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS repos
JOIN GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES licenses
ON repos."repo_name" = licenses."repo_name"
WHERE licenses."license" = 'isc' -- Adjusting to a likely existing license type based on sample data
ORDER BY repos."watch_count" DESC NULLS LAST
LIMIT 1;