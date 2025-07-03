WITH MonthlyFilings AS (
    SELECT 
        DATE_TRUNC('month', TO_DATE(CAST("filing_date" AS STRING), 'YYYYMMDD')) AS "month",
        COUNT(DISTINCT "publication_number") AS "publication_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t,
         LATERAL FLATTEN(input => t."abstract_localized") f
    WHERE t."country_code" = 'US'
      AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%'
    GROUP BY DATE_TRUNC('month', TO_DATE(CAST("filing_date" AS STRING), 'YYYYMMDD'))
),
AllMonths AS (
    SELECT 
        DATE_TRUNC('month', DATEADD(month, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2008-01-01')) AS "month"
    FROM TABLE(GENERATOR(ROWCOUNT => 180)) -- 180 months between Jan 2008 and Dec 2022
),
Result AS (
    SELECT 
        a."month",
        COALESCE(mf."publication_count", 0) AS "publications_count"
    FROM AllMonths a
    LEFT JOIN MonthlyFilings mf
    ON a."month" = mf."month"
)
SELECT * 
FROM Result
ORDER BY "month";