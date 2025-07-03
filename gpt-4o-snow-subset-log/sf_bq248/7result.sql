WITH python_excluded_repos AS (
  SELECT DISTINCT "repo_name" 
  FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES 
  WHERE "language" NOT ILIKE '%python%'
),
readme_files_with_copyright AS (
  SELECT DISTINCT sf."id"
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES sf
  JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc 
    ON sf."id" = sc."id"
  WHERE sf."repo_name" IN (SELECT "repo_name" FROM python_excluded_repos)
    AND sf."path" ILIKE '%readme.md%'
    AND sc."content" ILIKE '%Copyright (c)%'
),
readme_files_total AS (
  SELECT DISTINCT sf."id"
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES sf
  WHERE sf."repo_name" IN (SELECT "repo_name" FROM python_excluded_repos)
    AND sf."path" ILIKE '%readme.md%'
)
SELECT 
  COUNT(rwc."id")::FLOAT / NULLIF(COUNT(rft."id"), 0) AS "proportion"
FROM readme_files_total rft
LEFT JOIN readme_files_with_copyright rwc
  ON rft."id" = rwc."id";