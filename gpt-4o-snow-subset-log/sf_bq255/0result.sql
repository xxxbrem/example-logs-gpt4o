SELECT COUNT("SAMPLE_COMMITS"."message") AS "commit_message_count"
FROM GITHUB_REPOS.GITHUB_REPOS.LICENSES AS "LICENSES"
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES AS "LANGUAGES"
  ON "LICENSES"."repo_name" = "LANGUAGES"."repo_name"
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS AS "SAMPLE_COMMITS"
  ON "LANGUAGES"."repo_name" = "SAMPLE_COMMITS"."repo_name"
WHERE LOWER("LANGUAGES"."language") LIKE '%shell%'
  AND LOWER("LICENSES"."license") = 'apache-2.0'
  AND LENGTH("SAMPLE_COMMITS"."message") > 5
  AND LENGTH("SAMPLE_COMMITS"."message") < 10000
  AND LOWER("SAMPLE_COMMITS"."message") NOT LIKE 'merge%'
  AND LOWER("SAMPLE_COMMITS"."message") NOT LIKE 'update%'
  AND LOWER("SAMPLE_COMMITS"."message") NOT LIKE 'test%';