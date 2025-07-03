WITH PYTHON_IMPORTS AS (
    SELECT 
        'Python' AS language,
        REGEXP_SUBSTR(l."content", '(import|from\\s+)(\\w+)', 2, 1, 'i', 2) AS module
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS l
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f
        ON l."id" = f."id"
    WHERE f."path" LIKE '%.py' 
        AND l."content" ILIKE '%import%'
),
R_LIBRARIES AS (
    SELECT 
        'R' AS language,
        REGEXP_SUBSTR(l."content", 'library\\((\\w+)\\)', 1, 1, 'i', 1) AS module
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS l
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f
        ON l."id" = f."id"
    WHERE f."path" LIKE '%.r' 
        AND l."content" ILIKE '%library(%'
),
MODULE_COUNTS AS (
    SELECT 
        language,
        module,
        COUNT(*) AS occurrences
    FROM (
        SELECT * FROM PYTHON_IMPORTS
        UNION ALL
        SELECT * FROM R_LIBRARIES
    ) subquery
    WHERE module IS NOT NULL
    GROUP BY language, module
)
SELECT 
    language, 
    module, 
    occurrences
FROM MODULE_COUNTS
ORDER BY language, occurrences DESC NULLS LAST, module;