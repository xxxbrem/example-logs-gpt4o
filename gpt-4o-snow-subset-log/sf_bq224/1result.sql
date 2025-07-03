SELECT 
    r."repo_name",
    l."license",
    (r."watch_count" + COALESCE(f.forks, 0) + COALESCE(i.issues, 0)) AS total_activity
FROM 
    "GITHUB_REPOS_DATE"."GITHUB_REPOS"."LICENSES" l
JOIN 
    "GITHUB_REPOS_DATE"."GITHUB_REPOS"."SAMPLE_REPOS" r
ON 
    l."repo_name" = r."repo_name"
LEFT JOIN 
    (SELECT "repo_name", COUNT(*) AS forks 
     FROM "GITHUB_REPOS_DATE"."GITHUB_REPOS"."SAMPLE_FILES" 
     GROUP BY "repo_name") f
ON 
    r."repo_name" = f."repo_name"
LEFT JOIN 
    (SELECT "repo_name", COUNT(*) AS issues 
     FROM "GITHUB_REPOS_DATE"."GITHUB_REPOS"."SAMPLE_FILES" 
     GROUP BY "repo_name") i
ON 
    r."repo_name" = i."repo_name"
WHERE 
    l."license" IN ('epl-1.0', 'isc', 'mit', 'apache-2.0', 'gpl')
ORDER BY 
    total_activity DESC NULLS LAST
LIMIT 1;