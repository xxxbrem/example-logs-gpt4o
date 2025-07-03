SELECT 
    SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4) AS "ipc_4digit", 
    COUNT(*) AS "frequency"
FROM 
    PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."ipc") f
WHERE 
    t."country_code" = 'US' 
    AND t."kind_code" = 'B2' 
    AND t."application_kind" = 'A' 
    AND t."grant_date" BETWEEN 20220601 AND 20220831
GROUP BY 
    "ipc_4digit"
ORDER BY 
    "frequency" DESC NULLS LAST
LIMIT 1;