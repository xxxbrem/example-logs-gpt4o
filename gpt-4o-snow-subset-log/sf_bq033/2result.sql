WITH FilingDates AS (
  SELECT 
    DATE_TRUNC('MONTH', TO_DATE(CAST("filing_date" AS STRING), 'YYYYMMDD')) AS "filing_month"
  FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."abstract_localized") f
  WHERE 
    t."country_code" = 'US' 
    AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%'
),
AllMonths AS (
  SELECT 
    DATE_TRUNC('MONTH', DATEADD(MONTH, seq4(), '2008-01-01')) AS "month"
  FROM TABLE(GENERATOR(ROWCOUNT => 12 * (2022 - 2008 + 1)))
),
MergedData AS (
  SELECT 
    a."month", 
    COUNT(f."filing_month") AS "num_filings"
  FROM AllMonths a
  LEFT JOIN FilingDates f
    ON a."month" = f."filing_month"
  GROUP BY a."month"
)
SELECT 
  "month", 
  COALESCE("num_filings", 0) AS "num_filings"
FROM MergedData
ORDER BY "month";