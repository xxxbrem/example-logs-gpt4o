WITH CPC_FLATTENED AS (
    -- Flatten the "cpc" column and filter for the A01B3 class
    SELECT 
        t."family_id",
        t."assignee_harmonized",
        f.value::VARIANT:"code"::STRING AS "cpc_code",
        t."publication_date",
        t."country_code",
        CAST(SUBSTR(t."publication_date"::STRING, 1, 4) AS INT) AS "publication_year"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"code"::STRING ILIKE 'A01B3%'
),
ASSIGNEE_EXPLODED AS (
    -- Extracting assignee details with JSON-parsing to normalize the name and country_code
    SELECT 
        a."family_id",
        a."cpc_code",
        a."publication_date",
        a."publication_year",
        a."country_code",
        TRIM(JSON_EXTRACT_PATH_TEXT(e.value::VARIANT, 'name'), '"') AS "assignee_name",
        TRIM(JSON_EXTRACT_PATH_TEXT(e.value::VARIANT, 'country_code'), '"') AS "assignee_country"
    FROM CPC_FLATTENED a, LATERAL FLATTEN(input => a."assignee_harmonized") e
),
ASSIGNEE_STATS AS (
    -- Aggregate to get total application count and group by assignee and year
    SELECT 
        "assignee_name",
        "publication_year",
        COUNT(*) AS "application_count"
    FROM ASSIGNEE_EXPLODED
    GROUP BY "assignee_name", "publication_year"
),
TOP_YEARS AS (
    -- Identify the most active year for each assignee
    SELECT
        "assignee_name",
        "publication_year" AS "top_year",
        MAX("application_count") AS "max_count"
    FROM ASSIGNEE_STATS
    GROUP BY "assignee_name", "publication_year"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY "assignee_name" ORDER BY "max_count" DESC) = 1
),
TOP_ASSIGNEES AS (
    -- Aggregate total applications per assignee for ranking and find the top 3
    SELECT 
        "assignee_name",
        SUM("application_count") AS "total_applications"
    FROM ASSIGNEE_STATS
    GROUP BY "assignee_name"
    ORDER BY "total_applications" DESC NULLS LAST
    LIMIT 3
)
-- Join top assignee data with their most active year information
SELECT 
    t."assignee_name",
    t."total_applications",
    y."top_year",
    y."max_count" AS "applications_in_top_year"
FROM TOP_ASSIGNEES t
LEFT JOIN TOP_YEARS y
ON t."assignee_name" = y."assignee_name"
ORDER BY t."total_applications" DESC NULLS LAST;