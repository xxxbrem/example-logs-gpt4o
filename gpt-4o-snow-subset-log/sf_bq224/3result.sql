SELECT 
    r."repo_name",
    COALESCE(r."watch_count", 0) AS combined_total
FROM GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES l
JOIN GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_REPOS r
ON l."repo_name" = r."repo_name"
ORDER BY combined_total DESC NULLS LAST
LIMIT 1;