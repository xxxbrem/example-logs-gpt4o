WITH Flattened_Languages AS (
    SELECT 
        t."repo_name", 
        f.value:bytes::INTEGER AS "bytes", 
        f.value:name::STRING AS "language_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES t, 
    LATERAL FLATTEN(input => t."language") f
),
JavaScript_Repos AS (
    SELECT 
        "repo_name", 
        SUM("bytes") AS "total_bytes"
    FROM Flattened_Languages
    WHERE "language_name" ILIKE 'JavaScript'
    GROUP BY "repo_name"
),
Commit_Counts AS (
    SELECT 
        "repo_name", 
        COUNT("commit") AS "commit_count"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS
    GROUP BY "repo_name"
)
SELECT 
    c."repo_name", 
    c."commit_count"
FROM Commit_Counts c
JOIN JavaScript_Repos j
ON c."repo_name" = j."repo_name"
ORDER BY c."commit_count" DESC NULLS LAST
LIMIT 2;