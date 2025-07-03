WITH TopAssignees AS (
    SELECT 
        t."assignee_harmonized"[0]::STRING AS "assignee_name",
        COUNT(DISTINCT t."family_id") AS "total_applications"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE '%A01B3%'
    GROUP BY 
        t."assignee_harmonized"[0]::STRING
    ORDER BY 
        "total_applications" DESC NULLS LAST
    LIMIT 3
),
YearWithMostApplications AS (
    SELECT 
        t."assignee_harmonized"[0]::STRING AS "assignee_name",
        t."priority_date",
        COUNT(DISTINCT t."family_id") AS "yearly_applications",
        ROW_NUMBER() OVER (PARTITION BY t."assignee_harmonized"[0]::STRING ORDER BY COUNT(DISTINCT t."family_id") DESC) AS rn
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE '%A01B3%'
    GROUP BY 
        t."assignee_harmonized"[0]::STRING, 
        t."priority_date"
),
CountryWithMostApplications AS (
    SELECT 
        t."assignee_harmonized"[0]::STRING AS "assignee_name",
        t."priority_date",
        t."country_code",
        COUNT(DISTINCT t."family_id") AS "country_applications",
        ROW_NUMBER() OVER (PARTITION BY t."assignee_harmonized"[0]::STRING, t."priority_date" ORDER BY COUNT(DISTINCT t."family_id") DESC) AS rn
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.value::VARIANT:"code"::STRING ILIKE '%A01B3%'
    GROUP BY 
        t."assignee_harmonized"[0]::STRING, 
        t."priority_date", 
        t."country_code"
)
SELECT 
    ta."assignee_name",
    ta."total_applications",
    ywma."priority_date" AS "year_with_most_applications",
    ywma."yearly_applications",
    cwmma."country_code" AS "country_with_most_applications_during_year"
FROM 
    TopAssignees ta
LEFT JOIN 
    YearWithMostApplications ywma
    ON ta."assignee_name" = ywma."assignee_name" AND ywma.rn = 1
LEFT JOIN 
    CountryWithMostApplications cwmma
    ON ta."assignee_name" = cwmma."assignee_name" AND ywma."priority_date" = cwmma."priority_date" AND cwmma.rn = 1;