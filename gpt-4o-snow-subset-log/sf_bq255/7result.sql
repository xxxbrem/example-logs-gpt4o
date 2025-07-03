SELECT COUNT(*) AS "commit_message_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS sc
JOIN GITHUB_REPOS.GITHUB_REPOS.LICENSES lic 
ON sc."repo_name" = lic."repo_name"
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l 
ON sc."repo_name" = l."repo_name", 
LATERAL FLATTEN(input => l."language") f
WHERE f.value:"name"::STRING ILIKE 'Shell'
  AND lic."license" ILIKE 'apache-2.0%'
  AND LENGTH(sc."message") > 5 
  AND LENGTH(sc."message") < 10000
  AND LOWER(sc."message") NOT LIKE 'merge%'
  AND LOWER(sc."message") NOT LIKE 'update%'
  AND LOWER(sc."message") NOT LIKE 'test%';