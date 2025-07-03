WITH AssigneeApplicationCounts AS (
    SELECT f.value::VARIANT:"name"::STRING AS "assignee_harmonized_name", 
           COUNT(DISTINCT t."family_id") AS "application_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE t."family_id" IN (
        SELECT DISTINCT t."family_id"
        FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
        WHERE f.value::VARIANT:"code"::STRING LIKE 'A61%'
    )
    GROUP BY f.value::VARIANT:"name"::STRING
    ORDER BY "application_count" DESC
    LIMIT 1
),
TopFilingYear AS (
    SELECT f.value::VARIANT:"name"::STRING AS "assignee_harmonized_name", 
           YEAR(TO_DATE(TO_CHAR(t."filing_date"), 'YYYYMMDD')) AS "filing_year", 
           COUNT(DISTINCT t."family_id") AS "application_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE f.value::VARIANT:"name"::STRING = (
        SELECT "assignee_harmonized_name" FROM AssigneeApplicationCounts
    )
      AND t."family_id" IN (
          SELECT DISTINCT t."family_id"
          FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."cpc") f
          WHERE f.value::VARIANT:"code"::STRING LIKE 'A61%'
      )
    GROUP BY f.value::VARIANT:"name"::STRING, 
             YEAR(TO_DATE(TO_CHAR(t."filing_date"), 'YYYYMMDD'))
    ORDER BY "application_count" DESC, "filing_year" ASC
    LIMIT 1
)
SELECT "assignee_harmonized_name", "filing_year", "application_count"
FROM TopFilingYear;