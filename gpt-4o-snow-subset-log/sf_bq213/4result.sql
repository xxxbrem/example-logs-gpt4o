SELECT 
    SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4) AS "ipc4", 
    COUNT(*) AS "ipc4_count"
FROM 
    PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."ipc") f 
WHERE 
    t."country_code" = 'US' 
    AND t."kind_code" = 'B2' 
    AND t."application_kind" = 'A'
    AND t."grant_date" >= 20220601 
    AND t."grant_date" <= 20220831
GROUP BY 
    "ipc4"
ORDER BY 
    "ipc4_count" DESC NULLS LAST
LIMIT 1;