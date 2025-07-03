WITH DateRange AS (
    SELECT TO_DATE(DATEADD(MONTH, ROW_NUMBER() OVER (ORDER BY SEQ4()), '2008-01-01')) AS "month_year"
    FROM TABLE(GENERATOR(ROWCOUNT => 180)) -- 180 months = 15 years (2008 to 2022 inclusive)
),
FilteredPublications AS (
    SELECT 
        TO_CHAR(DATE_FROM_PARTS(LEFT(t."filing_date"::STRING, 4)::NUMBER, SUBSTR(t."filing_date"::STRING, 5, 2)::NUMBER, 01), 'YYYY-MM') AS "month_year_filing",
        COUNT(*) AS "publication_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t,
         LATERAL FLATTEN(input => t."abstract_localized") f
    WHERE t."country_code" = 'US'
      AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%'
    GROUP BY TO_CHAR(DATE_FROM_PARTS(LEFT(t."filing_date"::STRING, 4)::NUMBER, SUBSTR(t."filing_date"::STRING, 5, 2)::NUMBER, 01), 'YYYY-MM')
)
SELECT 
    TO_CHAR(d."month_year", 'YYYY-MM') AS "month_year",
    COALESCE(fp."publication_count", 0) AS "publication_count"
FROM DateRange d
LEFT JOIN FilteredPublications fp
ON TO_CHAR(d."month_year", 'YYYY-MM') = fp."month_year_filing"
ORDER BY d."month_year";