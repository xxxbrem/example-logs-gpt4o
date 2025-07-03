WITH TopAssignee AS (
    SELECT "assignee_harmonized", COUNT(*) AS "application_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"code"::STRING ILIKE 'A61%'
    GROUP BY "assignee_harmonized"
    ORDER BY "application_count" DESC NULLS LAST
    LIMIT 1
),
YearlyApplicationCounts AS (
    SELECT 
        YEAR(DATE_FROM_PARTS((t."filing_date" / 10000)::INT, ((t."filing_date" % 10000) / 100)::INT, (t."filing_date" % 100)::INT)) AS "year", 
        COUNT(*) AS "applications"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"code"::STRING ILIKE 'A61%'
      AND t."assignee_harmonized" = (SELECT "assignee_harmonized" FROM TopAssignee)
    GROUP BY "year"
    ORDER BY "applications" DESC NULLS LAST
    LIMIT 1
)
SELECT * 
FROM YearlyApplicationCounts;