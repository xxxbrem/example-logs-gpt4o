SELECT lang."repo_name", COUNT(sc."commit") AS "commit_count" 
FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang 
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS sc 
ON lang."repo_name" = sc."repo_name", LATERAL FLATTEN(input => lang."language") f 
WHERE f.value::VARIANT::STRING ILIKE '%JavaScript%' 
GROUP BY lang."repo_name" 
ORDER BY COUNT(sc."commit") DESC NULLS LAST 
LIMIT 2;