SELECT COUNT(DISTINCT c."message") AS "valid_commit_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS c
JOIN (
    SELECT DISTINCT l."repo_name", f.value::STRING AS "language_detail"
    FROM GITHUB_REPOS.GITHUB_REPOS.LICENSES l
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang 
    ON l."repo_name" = lang."repo_name", LATERAL FLATTEN(input => lang."language") f
    WHERE l."license" = 'apache-2.0' 
      AND f.value::STRING LIKE '%"name":"Shell"%'
) repo_filtered
ON c."repo_name" = repo_filtered."repo_name"
WHERE LENGTH(c."message") > 5 
  AND LENGTH(c."message") < 10000 
  AND LOWER(SPLIT_PART(c."message", ' ', 1)) NOT IN ('merge', 'update', 'test');