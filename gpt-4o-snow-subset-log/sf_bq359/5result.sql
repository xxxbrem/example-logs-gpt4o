WITH JavaScript_repos AS (
    SELECT DISTINCT l."repo_name", t.value::VARIANT AS "language"
    FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l, LATERAL FLATTEN(input => l."language") t
    WHERE t.value ILIKE '%JavaScript%'
),
Commit_counts AS (
    SELECT sc."repo_name", COUNT(*) AS "commit_count"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS sc
    GROUP BY sc."repo_name"
)
SELECT jc."repo_name", cc."commit_count"
FROM JavaScript_repos jc
JOIN Commit_counts cc
ON jc."repo_name" = cc."repo_name"
ORDER BY cc."commit_count" DESC NULLS LAST
LIMIT 2;