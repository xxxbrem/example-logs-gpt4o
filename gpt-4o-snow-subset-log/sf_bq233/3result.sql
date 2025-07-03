WITH Python_R_Files AS (
    SELECT f."id", f."path", c."content"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
    ON f."id" = c."id"
    WHERE f."path" ILIKE '%.py' OR f."path" ILIKE '%.r'
),
Extracted_Imports AS (
    SELECT 
        CASE 
            WHEN "path" ILIKE '%.py' THEN 'Python'
            WHEN "path" ILIKE '%.r' THEN 'R'
        END AS "language",
        REGEXP_SUBSTR("content", 
            CASE 
                WHEN "path" ILIKE '%.py' THEN '\\bimport\\s(\\w+)|\\bfrom\\s(\\w+)'
                WHEN "path" ILIKE '%.r' THEN '\\blibrary\\(\\s*([a-zA-Z0-9._]+)\\s*\\)'
            END, 
            1, 1, 'c', 1) AS "module_or_library"
    FROM Python_R_Files
),
Filtered_NonNull_Imports AS (
    SELECT "language", "module_or_library"
    FROM Extracted_Imports
    WHERE "module_or_library" IS NOT NULL
),
Counted_Imports AS (
    SELECT "language", "module_or_library", COUNT(*) AS "occurrences"
    FROM Filtered_NonNull_Imports
    GROUP BY "language", "module_or_library"
)
SELECT "language", "module_or_library", "occurrences"
FROM Counted_Imports
ORDER BY "language", "occurrences" DESC NULLS LAST;