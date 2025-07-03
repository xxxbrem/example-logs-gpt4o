WITH MONTHLY_FILINGS AS (
    SELECT 
        DATE_PART('YEAR', TO_DATE(t."filing_date"::STRING, 'YYYYMMDD')) AS "year",
        DATE_PART('MONTH', TO_DATE(t."filing_date"::STRING, 'YYYYMMDD')) AS "month",
        COUNT(*) AS "filing_count"
    FROM PATENTS.PATENTS.PUBLICATIONS t,
         LATERAL FLATTEN(input => t."abstract_localized") f
    WHERE t."country_code" = 'US'
      AND f.value::VARIANT:"text"::STRING ILIKE '%internet of things%'
      AND t."filing_date" >= 20080101
      AND t."filing_date" <= 20221231
    GROUP BY "year", "month"
),
ALL_MONTHS AS (
    SELECT 
        y."year", 
        m AS "month"
    FROM 
        (SELECT SEQ4() + 2008 AS "year" FROM TABLE(GENERATOR(ROWCOUNT => 15))) y, 
        LATERAL (SELECT SEQ4() + 1 AS m FROM TABLE(GENERATOR(ROWCOUNT => 12))) m
    WHERE y."year" <= 2022 AND m <= 12
)
SELECT 
    a."year", 
    a."month", 
    COALESCE(mf."filing_count", 0) AS "filing_count"
FROM ALL_MONTHS a
LEFT JOIN MONTHLY_FILINGS mf
    ON a."year" = mf."year" AND a."month" = mf."month"
ORDER BY a."year", a."month";