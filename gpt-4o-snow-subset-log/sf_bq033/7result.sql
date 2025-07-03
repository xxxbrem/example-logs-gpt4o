WITH Monthly_Filings AS (
    SELECT 
        LEFT(CAST("filing_date" AS STRING), 6) AS "filing_month", 
        COUNT(*) AS "iot_publications"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."abstract_localized") f
    WHERE t."country_code" = 'US' 
      AND t."filing_date" BETWEEN 20080000 AND 20221231
      AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%'
    GROUP BY "filing_month"
),
All_Months AS (
    SELECT TO_CHAR(DATE_TRUNC('month', DATEADD(month, ROW_NUMBER() OVER(ORDER BY SEQ4()), '2008-01-01')::DATE), 'YYYYMM') AS "filing_month"
    FROM TABLE(GENERATOR(ROWCOUNT => 12 * (2022 - 2008 + 1)))
)
SELECT 
    am."filing_month", 
    COALESCE(mf."iot_publications", 0) AS "iot_publications"
FROM All_Months am
LEFT JOIN Monthly_Filings mf
ON am."filing_month" = mf."filing_month"
ORDER BY am."filing_month";