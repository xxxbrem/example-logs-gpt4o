SELECT 
    SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4) AS "ipc4_code", 
    COUNT(*) AS "most_common_count" 
FROM 
    PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => TRY_PARSE_JSON(t."ipc")) f 
WHERE 
    t."country_code" = 'US' 
    AND t."kind_code" = 'B2' 
    AND t."grant_date" BETWEEN 20220601 AND 20220831
GROUP BY 
    SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4)
ORDER BY 
    "most_common_count" DESC NULLS LAST
LIMIT 1;