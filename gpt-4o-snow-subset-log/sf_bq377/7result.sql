WITH JSON_CONTENT AS (
    -- Extract rows with JSON-like patterns in the "content" column, potentially containing a "require" section
    SELECT "id", "content"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS
    WHERE "content" ILIKE '%"require"%'
),
PARSED_REQUIRE_SECTION AS (
    -- Extract the JSON structure for the "require" section
    SELECT
        "id",
        TRIM(
            REGEXP_SUBSTR(
                "content", 
                '"require":\\s*\\{[^\\}]*\\}', 
                1, 1, 'e'
            ),
            '"require":'
        ) AS "require_section"
    FROM JSON_CONTENT
    WHERE REGEXP_SUBSTR("content", '"require":\\s*\\{[^\\}]*\\}', 1, 1, 'e') IS NOT NULL
),
PACKAGE_COUNTS AS (
    -- Extract individual package names from the "require" section
    SELECT
        "id",
        REGEXP_SUBSTR("require_section", '"([^"]+)":', 1, ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY NULL), 'e') AS "package_name"
    FROM PARSED_REQUIRE_SECTION
    QUALIFY REGEXP_SUBSTR("require_section", '"([^"]+)":', 1, ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY NULL), 'e') IS NOT NULL
)
-- Count the frequency of each package name
SELECT 
    "package_name",
    COUNT(*) AS "frequency"
FROM PACKAGE_COUNTS
GROUP BY "package_name"
ORDER BY "frequency" DESC NULLS LAST;