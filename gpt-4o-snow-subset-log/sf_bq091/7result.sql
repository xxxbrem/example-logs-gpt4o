WITH AssigneeFilingCounts AS (
    SELECT 
        f.value::VARIANT:"name"::STRING AS "assignee_name", 
        "filing_date"::STRING AS "year", 
        COUNT(*) AS "application_count"
    FROM 
        "PATENTS"."PATENTS"."PUBLICATIONS" t, 
        LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE 
        "ipc" ILIKE '%A61%'
    GROUP BY 
        "filing_date"::STRING, f.value::VARIANT:"name"::STRING
),
TopAssignee AS (
    SELECT 
        "assignee_name"
    FROM 
        AssigneeFilingCounts
    GROUP BY 
        "assignee_name"
    ORDER BY 
        SUM("application_count") DESC NULLS LAST
    LIMIT 1
)
SELECT 
    afc."year", 
    afc."application_count"
FROM 
    AssigneeFilingCounts afc
JOIN 
    TopAssignee ta
ON 
    afc."assignee_name" = ta."assignee_name"
ORDER BY 
    afc."application_count" DESC NULLS LAST
LIMIT 1;