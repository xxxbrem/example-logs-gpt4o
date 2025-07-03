WITH python_repos AS (
    -- Filter for repositories that primarily use Python
    SELECT DISTINCT sf."repo_name", sf."id"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES sf
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang ON sf."repo_name" = lang."repo_name"
    WHERE sf."path" ILIKE '%README.md%' AND lang."language" ILIKE '%python%'
),
readme_content AS (
    -- Get README.md content for Python repositories
    SELECT sc."content", sc."sample_repo_name" AS "repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc
    JOIN python_repos filtered_sf ON sc."id" = filtered_sf."id"
),
non_empty_lines AS (
    -- Extract non-empty, non-commented lines from README.md files
    SELECT
        "repo_name",
        TRIM(VALUE) AS "line"
    FROM (
        SELECT
            "repo_name",
            SPLIT("content", '\n') AS LINES
        FROM readme_content
    ), TABLE(FLATTEN(INPUT => LINES))
    WHERE TRIM(VALUE) != '' -- Exclude empty lines
      AND TRIM(VALUE) NOT LIKE '#%' -- Exclude Markdown comments
      AND TRIM(VALUE) NOT LIKE '--%' -- Exclude SQL-style comments
      AND TRIM(VALUE) NOT LIKE '//%' -- Exclude code comments
),
line_frequency AS (
    -- Calculate the frequency of each unique line of text and combine languages
    SELECT
        nl."line",
        COUNT(DISTINCT nl."repo_name") AS "frequency",
        ARRAY_AGG(DISTINCT lang."language") AS "languages"
    FROM non_empty_lines nl
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang ON nl."repo_name" = lang."repo_name"
    GROUP BY nl."line"
),
sorted_results AS (
    -- Order by frequency in descending order
    SELECT "line", "frequency", "languages"
    FROM line_frequency
    ORDER BY "frequency" DESC NULLS LAST
)
-- Retrieve the top 5 most frequently occurring lines
SELECT "line", "frequency", ARRAY_TO_STRING("languages", ', ') AS "languages"
FROM sorted_results
LIMIT 5;