SELECT 
    CASE 
        WHEN sf."path" ILIKE '%.py%' THEN 'Python'
        WHEN sf."path" ILIKE '%.r%' THEN 'R'
    END AS "language",
    TRIM(SPLIT_PART(SPLIT_PART(sc."content", 'import ', 2), ' ', 1)) AS "module_or_library",
    COUNT(*) AS "occurrences"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc 
    ON sf."id" = sc."id"
WHERE 
    (sf."path" ILIKE '%.py%' AND (sc."content" ILIKE '%import %' OR sc."content" ILIKE '%from % import%'))
    OR 
    (sf."path" ILIKE '%.r%' AND sc."content" ILIKE '%library(%')
GROUP BY 
    CASE 
        WHEN sf."path" ILIKE '%.py%' THEN 'Python'
        WHEN sf."path" ILIKE '%.r%' THEN 'R'
    END,
    TRIM(SPLIT_PART(SPLIT_PART(sc."content", 'import ', 2), ' ', 1))
ORDER BY 
    "language",
    "occurrences" DESC NULLS LAST;