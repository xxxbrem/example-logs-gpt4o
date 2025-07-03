SELECT COUNT(t3."message") AS "commit_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_COMMITS" t3
WHERE t3."repo_name" IN 
(
    SELECT DISTINCT t1."repo_name"
    FROM 
    (
        SELECT DISTINCT t1."repo_name" 
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" t1, LATERAL FLATTEN(input => t1."language") f
        WHERE f.value::STRING ILIKE '%Shell%'
    ) t1
    INNER JOIN 
    (
        SELECT DISTINCT t2."repo_name" 
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."LICENSES" t2
        WHERE t2."license" ILIKE 'apache-2.0'
    ) t2
    ON t1."repo_name" = t2."repo_name"
)
AND LENGTH(t3."message") > 5 
AND LENGTH(t3."message") < 10000
AND t3."message" NOT ILIKE 'merge%'
AND t3."message" NOT ILIKE 'update%'
AND t3."message" NOT ILIKE 'test%';