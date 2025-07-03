SELECT COUNT(c."message") AS "commit_message_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS c
WHERE c."repo_name" IN (
    SELECT DISTINCT l."repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
    INNER JOIN GITHUB_REPOS.GITHUB_REPOS.LICENSES lic
        ON l."repo_name" = lic."repo_name"
    WHERE l."language" ILIKE '%Shell%' 
        AND lic."license" ILIKE 'apache-2.0'
)
AND LENGTH(c."message") > 5 
AND LENGTH(c."message") < 10000
AND LOWER(c."message") NOT LIKE 'merge%' 
AND LOWER(c."message") NOT LIKE 'update%' 
AND LOWER(c."message") NOT LIKE 'test%';