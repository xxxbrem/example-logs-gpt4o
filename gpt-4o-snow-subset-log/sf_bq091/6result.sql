WITH Assignee_Application_Count AS (
    SELECT 
        f.value::VARIANT:"name"::STRING AS "assignee_harmonized",
        t."filing_date"::STRING AS "filing_year",
        COUNT(*) AS "application_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE t."cpc"::TEXT ILIKE '%A61%'
    GROUP BY f.value::VARIANT:"name"::STRING, t."filing_date"::STRING
),
Top_Assignee AS (
    SELECT 
        "assignee_harmonized",
        SUM("application_count") AS "total_applications"
    FROM Assignee_Application_Count
    GROUP BY "assignee_harmonized"
    ORDER BY "total_applications" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    a."filing_year",
    a."application_count"
FROM Assignee_Application_Count a
JOIN Top_Assignee t
ON a."assignee_harmonized" = t."assignee_harmonized"
ORDER BY a."application_count" DESC NULLS LAST
LIMIT 1;