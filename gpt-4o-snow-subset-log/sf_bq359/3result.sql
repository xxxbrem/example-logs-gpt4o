SELECT sc."repo_name", COUNT(*) AS "commit_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS sc
JOIN (
    SELECT DISTINCT t."repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES t,
    LATERAL FLATTEN(input => t."language") f
    WHERE f.value::VARIANT::STRING ILIKE '%JavaScript%'
) js_repos ON sc."repo_name" = js_repos."repo_name"
GROUP BY sc."repo_name"
ORDER BY "commit_count" DESC NULLS LAST
LIMIT 2;