WITH PullRequestsPerRepo AS (
    SELECT 
        e."repo"::VARIANT:"name"::STRING AS "repo_name", 
        COUNT(e."id") AS pull_request_count
    FROM GITHUB_REPOS_DATE.YEAR._2023 e
    WHERE e."type" = 'PullRequestEvent' 
      AND e."created_at" BETWEEN 1674000000000000 AND 1674086399000000
    GROUP BY e."repo"::VARIANT:"name"::STRING
),
PrimaryLanguageBytes AS (
    SELECT 
        l."repo_name", 
        MAX(t.value::VARIANT:"bytes"::NUMBER) AS max_bytes, 
        MAX(t.value::VARIANT:"name"::STRING) AS primary_language
    FROM GITHUB_REPOS_DATE.GITHUB_REPOS.LANGUAGES l,
         LATERAL FLATTEN(input => l."language") t
    GROUP BY l."repo_name"
),
PullRequestsByLanguage AS (
    SELECT 
        plb.primary_language, 
        SUM(pr.pull_request_count) AS total_pull_requests
    FROM PullRequestsPerRepo pr
    LEFT JOIN PrimaryLanguageBytes plb
    ON pr."repo_name" = plb."repo_name"
    GROUP BY plb.primary_language
)
SELECT primary_language, total_pull_requests
FROM PullRequestsByLanguage
WHERE total_pull_requests >= 100
ORDER BY total_pull_requests DESC NULLS LAST;