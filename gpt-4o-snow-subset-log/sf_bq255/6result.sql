SELECT COUNT(*) AS "total_commits" 
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_COMMITS" c 
JOIN (
    SELECT l."repo_name" 
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l 
    JOIN "GITHUB_REPOS"."GITHUB_REPOS"."LICENSES" lc 
    ON l."repo_name" = lc."repo_name" 
    WHERE l."language" ILIKE '%Shell%' AND lc."license" = 'apache-2.0'
) filtered_repos 
ON c."repo_name" = filtered_repos."repo_name" 
WHERE LENGTH(c."message") > 5 
  AND LENGTH(c."message") < 10000 
  AND LOWER(c."message") NOT LIKE 'merge%' 
  AND LOWER(c."message") NOT LIKE 'update%' 
  AND LOWER(c."message") NOT LIKE 'test%';