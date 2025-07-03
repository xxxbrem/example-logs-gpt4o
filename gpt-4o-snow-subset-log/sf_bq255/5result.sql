SELECT COUNT(*) AS "total_commit_messages"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS c
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
ON c."repo_name" = l."repo_name"
JOIN GITHUB_REPOS.GITHUB_REPOS.LICENSES r
ON c."repo_name" = r."repo_name",
LATERAL FLATTEN(input => l."language") f
WHERE f.value::STRING ILIKE '%shell%'
  AND r."license" = 'apache-2.0'
  AND LENGTH(c."message") BETWEEN 5 AND 10000
  AND LOWER(c."message") NOT LIKE 'merge%'
  AND LOWER(c."message") NOT LIKE 'update%'
  AND LOWER(c."message") NOT LIKE 'test%';