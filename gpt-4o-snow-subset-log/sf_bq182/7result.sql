WITH FilteredEvents AS (
    -- Step 1: Filter PullRequestEvents on January 18, 2023
    SELECT 
        "repo"::VARIANT:"name"::STRING AS "repo_name"
    FROM 
        GITHUB_REPOS_DATE.YEAR._2023
    WHERE 
        "type" = 'PullRequestEvent'
        AND "created_at" BETWEEN 1674000000000000 AND 1674086399999999
),
RepoLanguages AS (
    -- Step 2: Extract primary language from LANGUAGES table, ensuring correct handling of nested JSON fields
    SELECT 
        "repo_name", 
        "language"::VARIANT[0]::OBJECT:"name"::STRING AS "primary_language", -- Extract primary language name
        "language"::VARIANT[0]::OBJECT:"bytes"::NUMBER AS "language_bytes"   -- Extract language bytes
    FROM 
        GITHUB_REPOS_DATE.GITHUB_REPOS.LANGUAGES
    WHERE 
        "language" IS NOT NULL
),
PullRequestCounts AS (
    -- Step 3: Join filtered events with RepoLanguages to count pull requests per primary language
    SELECT 
        rl."primary_language",
        COUNT(DISTINCT fe."repo_name") AS "pull_request_count" -- Use DISTINCT to handle duplicate case
    FROM 
        FilteredEvents fe
    LEFT JOIN 
        RepoLanguages rl
    ON 
        fe."repo_name" = rl."repo_name"
    WHERE 
        rl."primary_language" IS NOT NULL -- Retain rows with primary language
    GROUP BY 
        rl."primary_language"
)
-- Step 4: Check all languages without threshold restriction to validate results
SELECT 
    "primary_language", 
    "pull_request_count"
FROM 
    PullRequestCounts
WHERE 
    "pull_request_count" > 0
ORDER BY 
    "pull_request_count" DESC;