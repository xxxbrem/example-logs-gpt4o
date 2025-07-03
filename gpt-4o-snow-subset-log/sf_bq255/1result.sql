SELECT COUNT(c."message") AS "total_commit_messages" 
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_COMMITS" c 
INNER JOIN (
  SELECT DISTINCT l."repo_name" 
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l 
  INNER JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LICENSES" li 
  ON l."repo_name" = li."repo_name" 
  WHERE l."language" ILIKE '%Shell%' 
    AND li."license" ILIKE '%apache-2.0%'
) r 
ON c."repo_name" = r."repo_name" 
WHERE LENGTH(c."message") > 5 
  AND LENGTH(c."message") < 10000 
  AND LOWER(c."message") NOT LIKE 'merge%' 
  AND LOWER(c."message") NOT LIKE 'update%' 
  AND LOWER(c."message") NOT LIKE 'test%';