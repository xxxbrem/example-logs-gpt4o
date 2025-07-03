SELECT l."repo_name", COUNT(c."commit") AS "commit_count"
FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS c
ON l."repo_name" = c."repo_name",
LATERAL FLATTEN(input => l."language") f
WHERE f.value::VARIANT::STRING ILIKE '%JavaScript%'
GROUP BY l."repo_name"
ORDER BY "commit_count" DESC NULLS LAST
LIMIT 2;