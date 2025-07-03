WITH FilteredReadmeLines AS (
    SELECT 
        SPLIT(c."content", '\n') AS "lines",
        l."language"::TEXT AS "language"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
    ON c."sample_repo_name" = l."repo_name"
    WHERE c."sample_path" ILIKE '%readme.md%' 
    AND l."language" IS NOT NULL 
    AND l."language" ILIKE '%Python%'
),
NonEmptyLines AS (
    SELECT 
        TRIM(value) AS "line",
        "language"
    FROM FilteredReadmeLines,
         LATERAL FLATTEN(input => "lines")
    WHERE TRIM(value) <> '' -- Exclude empty lines
    AND NOT (TRIM(value) LIKE '#%' OR TRIM(value) LIKE '//%') -- Exclude comments
),
LineFrequency AS (
    SELECT 
        "line",
        COUNT(DISTINCT "language") AS "language_count",
        ARRAY_AGG(DISTINCT "language") AS "languages"
    FROM NonEmptyLines
    GROUP BY "line"
),
RankedLines AS (
    SELECT 
        "line",
        "language_count",
        ARRAY_TO_STRING("languages", ', ') AS "language_list",
        ROW_NUMBER() OVER (ORDER BY "language_count" DESC) AS "ranking"
    FROM LineFrequency
)
SELECT 
    "line",
    "language_list",
    "language_count"
FROM RankedLines
WHERE "ranking" <= 5
ORDER BY "language_count" DESC, "line" ASC;