WITH CPC_FILTER AS (
    SELECT t."assignee_harmonized", 
           t."publication_date" AS "year", 
           t."country_code",
           COUNT(*) AS "application_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"code"::STRING ILIKE '%A01B3%'
    GROUP BY t."assignee_harmonized", t."publication_date", t."country_code"
),
TOTAL_APPLICATIONS AS (
    SELECT "assignee_harmonized", 
           SUM("application_count") AS "total_applications"
    FROM CPC_FILTER
    GROUP BY "assignee_harmonized"
),
MOST_ACTIVE_YEAR AS (
    SELECT DISTINCT "assignee_harmonized", 
           "year" AS "most_active_year", 
           "application_count" AS "max_applications",
           "country_code" AS "country_code_with_most_applications"
    FROM CPC_FILTER
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY "assignee_harmonized" 
        ORDER BY "application_count" DESC, "year" ASC
    ) = 1
),
RESULT AS (
    SELECT TA."assignee_harmonized", 
           TA."total_applications", 
           MAY."most_active_year", 
           MAY."max_applications" AS "applications_in_most_active_year", 
           MAY."country_code_with_most_applications"
    FROM TOTAL_APPLICATIONS TA
    JOIN MOST_ACTIVE_YEAR MAY ON TA."assignee_harmonized" = MAY."assignee_harmonized"
    ORDER BY "total_applications" DESC NULLS LAST
    LIMIT 3
)
SELECT * 
FROM RESULT;