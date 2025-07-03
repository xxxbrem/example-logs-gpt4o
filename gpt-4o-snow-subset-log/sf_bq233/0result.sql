WITH Python_Imports AS (
    SELECT 
        REGEXP_SUBSTR("content", '\\bfrom\\s+([a-zA-Z0-9_.]+)\\s+import', 1, 1, 'e') AS "module",
        'Python' AS "language"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS"
    WHERE "id" IN (
        SELECT "id"
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES"
        WHERE "path" ILIKE '%.py'
    ) AND "content" ILIKE '%from%import%'
    UNION ALL
    SELECT 
        REGEXP_SUBSTR("content", '\\bimport\\s+([a-zA-Z0-9_.]+)', 1, 1, 'e') AS "module",
        'Python' AS "language"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS"
    WHERE "id" IN (
        SELECT "id"
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES"
        WHERE "path" ILIKE '%.py'
    ) AND "content" ILIKE '%import%'
),
R_Libraries AS (
    SELECT 
        REGEXP_SUBSTR("content", '\\blibrary\\(([^)]+)\\)', 1, 1, 'e') AS "module",
        'R' AS "language"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS"
    WHERE "id" IN (
        SELECT "id"
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES"
        WHERE "path" ILIKE '%.r'
    ) AND "content" ILIKE '%library(%'
),
Combined_Modules AS (
    SELECT * FROM Python_Imports
    UNION ALL
    SELECT * FROM R_Libraries
)
SELECT 
    "language",
    "module",
    COUNT(*) AS "occurrences"
FROM Combined_Modules
WHERE "module" IS NOT NULL
GROUP BY "language", "module"
ORDER BY "language", "occurrences" DESC NULLS LAST;