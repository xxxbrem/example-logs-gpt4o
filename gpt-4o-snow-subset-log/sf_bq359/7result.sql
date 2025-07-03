SELECT 
    lang."repo_name", 
    COUNT(commits."commit") AS "commit_count"
FROM 
    GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang
JOIN 
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS commits
ON 
    lang."repo_name" = commits."repo_name",
    LATERAL FLATTEN(input => lang."language") lang_flat
WHERE 
    lang_flat.value::STRING ILIKE '%"name":"JavaScript"%'
GROUP BY 
    lang."repo_name"
ORDER BY 
    "commit_count" DESC NULLS LAST
LIMIT 2;