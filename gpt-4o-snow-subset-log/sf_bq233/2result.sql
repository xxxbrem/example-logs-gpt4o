WITH Filtered_Files AS (
    SELECT t."id", t."path", c."content"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES t
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
    ON t."id" = c."id"
    WHERE t."path" ILIKE '%.py' OR t."path" ILIKE '%.r'
),
Extracted_Imports AS (
    SELECT
        'Python' AS language,
        REGEXP_SUBSTR(f."content", 'import\\s+([a-zA-Z_][a-zA-Z0-9_]*)', 1, 1, 'e', 1) AS module_or_library
    FROM Filtered_Files f
    WHERE f."path" ILIKE '%.py' AND f."content" ILIKE '%import %'
    UNION ALL
    SELECT
        'Python' AS language,
        REGEXP_SUBSTR(f."content", 'from\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s+import', 1, 1, 'e', 1) AS module_or_library
    FROM Filtered_Files f
    WHERE f."path" ILIKE '%.py' AND f."content" ILIKE '%from % import %'
    UNION ALL
    SELECT
        'R' AS language,
        REGEXP_SUBSTR(f."content", 'library\\(([^)]+)\\)', 1, 1, 'e', 1) AS module_or_library
    FROM Filtered_Files f
    WHERE f."path" ILIKE '%.r' AND f."content" ILIKE '%library(%'
),
Counted_Imports AS (
    SELECT
        language,
        module_or_library,
        COUNT(*) AS occurrences
    FROM Extracted_Imports
    WHERE module_or_library IS NOT NULL
    GROUP BY language, module_or_library
)
SELECT
    language,
    module_or_library,
    occurrences
FROM Counted_Imports
ORDER BY language, occurrences DESC NULLS LAST;