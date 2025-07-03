SELECT 
    TO_CHAR(TO_DATE(CAST(t."filing_date" AS STRING), 'YYYYMMDD'), 'YYYY-MM') AS "year_month",
    COUNT(*) AS "publication_count"
FROM PATENTS.PATENTS.PUBLICATIONS t, 
     LATERAL FLATTEN(input => t."abstract_localized") f
WHERE t."country_code" = 'US' 
    AND f.value::VARIANT:"text"::STRING ILIKE '%internet%of%things%'
    AND t."filing_date" >= 20080101 
    AND t."filing_date" <= 20221231
GROUP BY "year_month"
ORDER BY "year_month"