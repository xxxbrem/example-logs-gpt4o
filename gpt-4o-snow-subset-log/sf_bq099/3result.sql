WITH TopAssignees AS (
    -- Get the top 3 assignees with the most applications linked to CPC class A01B3
    SELECT 
        f.value::VARIANT:"name"::STRING AS "assignee_harmonized_text",
        COUNT(*) AS "total_applications"
    FROM PATENTS.PATENTS.PUBLICATIONS t, TABLE(FLATTEN(input => t."assignee_harmonized")) f
    WHERE t."cpc"::STRING ILIKE '%A01B3%'
    GROUP BY f.value::VARIANT:"name"::STRING
    ORDER BY "total_applications" DESC
    LIMIT 3
),
AssigneeDetails AS (
    -- For each top assignee, get the year with the most applications, total applications in that year, and the country code with the most applications
    SELECT 
        a."assignee_harmonized_text",
        a."total_applications",
        YEAR(DATE_FROM_PARTS(LEFT(t."publication_date"::TEXT, 4)::INTEGER, 1, 1)) AS "year",
        COUNT(*) AS "applications_in_year",
        t."country_code",
        ROW_NUMBER() OVER (PARTITION BY a."assignee_harmonized_text" ORDER BY COUNT(*) DESC NULLS LAST) AS "row_num"
    FROM PATENTS.PATENTS.PUBLICATIONS t, TABLE(FLATTEN(input => t."assignee_harmonized")) f
    INNER JOIN TopAssignees a
        ON f.value::VARIANT:"name"::STRING = a."assignee_harmonized_text"
    WHERE t."cpc"::STRING ILIKE '%A01B3%'
    GROUP BY a."assignee_harmonized_text", a."total_applications", YEAR(DATE_FROM_PARTS(LEFT(t."publication_date"::TEXT, 4)::INTEGER, 1, 1)), t."country_code"
)
-- Final selection: get the desired fields for top 3 assignees
SELECT 
    "assignee_harmonized_text" AS "assignee_name",
    "total_applications",
    "year" AS "year_with_most_applications",
    "applications_in_year" AS "total_applications_in_that_year",
    "country_code" AS "country_with_most_applications_that_year"
FROM AssigneeDetails
WHERE "row_num" = 1
ORDER BY "total_applications" DESC;