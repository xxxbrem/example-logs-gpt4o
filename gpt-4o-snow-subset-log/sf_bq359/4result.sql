SELECT l."repo_name", COUNT(sc."commit") AS "commit_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_COMMITS" sc ON l."repo_name" = sc."repo_name",
LATERAL FLATTEN(input => l."language") f
WHERE f.value::VARIANT::STRING ILIKE '%JavaScript%'
GROUP BY l."repo_name"
ORDER BY "commit_count" DESC NULLS LAST
LIMIT 2;