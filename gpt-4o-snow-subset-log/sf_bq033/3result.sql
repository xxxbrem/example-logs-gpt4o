WITH monthly_filing_count AS (
    SELECT 
       DATE_PART('YEAR', TO_DATE(TO_CHAR(t."filing_date"), 'YYYYMMDD')) AS "year",
       DATE_PART('MONTH', TO_DATE(TO_CHAR(t."filing_date"), 'YYYYMMDD')) AS "month",
       COUNT(*) AS "count"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."abstract_localized") f
    WHERE t."country_code" = 'US' 
      AND t."filing_date" > 0  -- Exclude invalid filing_date values
      AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%' 
      AND DATE_PART('YEAR', TO_DATE(TO_CHAR(t."filing_date"), 'YYYYMMDD')) BETWEEN 2008 AND 2022
    GROUP BY 1, 2
),
all_months AS (
    SELECT 
        y.year, 
        m.month
    FROM (SELECT SEQ4() + 2008 AS year FROM TABLE(GENERATOR(ROWCOUNT => 15))) y, -- Generate years from 2008 to 2022
         (SELECT SEQ4() + 1 AS month FROM TABLE(GENERATOR(ROWCOUNT => 12))) m   -- Generate months from 1 to 12
)
SELECT 
    a.year, 
    a.month, 
    COALESCE(mf."count", 0) AS "count"
FROM all_months a
LEFT JOIN monthly_filing_count mf
ON a.year = mf."year" AND a.month = mf."month"
ORDER BY a.year, a.month;