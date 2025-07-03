WITH AssigneeApplications AS (
    SELECT 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name') AS "assignee_name",
        COUNT(DISTINCT t."family_id") AS "total_applications"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE 'A01B3%'
    GROUP BY 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name')
),
TopAssignees AS (
    SELECT 
        "assignee_name",
        "total_applications"
    FROM 
        AssigneeApplications
    ORDER BY 
        "total_applications" DESC NULLS LAST
    LIMIT 3
),
AssigneeYearInfo AS (
    SELECT 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name') AS "assignee_name",
        LEFT(t."publication_date"::TEXT, 4) AS "publication_year",
        COUNT(t."family_id") AS "yearly_application_count"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE 'A01B3%'
    GROUP BY 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name'),
        LEFT(t."publication_date"::TEXT, 4)
),
MaxYearPerAssignee AS (
    SELECT 
        t1."assignee_name",
        t1."publication_year",
        t1."yearly_application_count",
        RANK() OVER (PARTITION BY t1."assignee_name" ORDER BY t1."yearly_application_count" DESC NULLS LAST) AS "rank"
    FROM 
        AssigneeYearInfo t1
    WHERE 
        t1."assignee_name" IN (SELECT "assignee_name" FROM TopAssignees)
),
TopYears AS (
    SELECT 
        t2."assignee_name",
        t2."publication_year",
        t2."yearly_application_count"
    FROM 
        MaxYearPerAssignee t2
    WHERE 
        t2."rank" = 1
),
CountryStats AS (
    SELECT 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name') AS "assignee_name",
        LEFT(t."publication_date"::TEXT, 4) AS "publication_year",
        t."country_code",
        COUNT(t."family_id") AS "country_application_count"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE 'A01B3%'
    GROUP BY 
        JSON_EXTRACT_PATH_TEXT(t."assignee_harmonized"[0], 'name'),
        LEFT(t."publication_date"::TEXT, 4),
        t."country_code"
),
TopCountryPerYear AS (
    SELECT 
        t3."assignee_name",
        t3."publication_year",
        t3."country_code",
        t3."country_application_count",
        RANK() OVER (PARTITION BY t3."assignee_name", t3."publication_year" ORDER BY t3."country_application_count" DESC NULLS LAST) AS "rank"
    FROM 
        CountryStats t3
    WHERE 
        t3."assignee_name" IN (SELECT "assignee_name" FROM TopAssignees)
),
FinalCountryPerYear AS (
    SELECT 
        t4."assignee_name",
        t4."publication_year",
        t4."country_code"
    FROM 
        TopCountryPerYear t4
    WHERE 
        t4."rank" = 1
)
SELECT 
    t5."assignee_name",
    t6."total_applications",
    t5."publication_year" AS "year_with_most_applications",
    t5."yearly_application_count",
    t7."country_code" AS "country_with_most_applications"
FROM 
    TopYears t5
JOIN 
    TopAssignees t6 ON t5."assignee_name" = t6."assignee_name"
JOIN 
    FinalCountryPerYear t7 ON t5."assignee_name" = t7."assignee_name" AND t5."publication_year" = t7."publication_year"
ORDER BY 
    t6."total_applications" DESC NULLS LAST;