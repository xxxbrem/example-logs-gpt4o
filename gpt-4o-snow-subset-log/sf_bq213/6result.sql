SELECT SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4) AS "most_common_ipc_4_digit",
       COUNT(*) AS "occurrences"
FROM PATENTS.PATENTS.PUBLICATIONS t, 
     LATERAL FLATTEN(input => t."ipc") f
WHERE t."country_code" = 'US' 
  AND t."kind_code" = 'B2'
  AND t."grant_date" BETWEEN 20220601 AND 20220831
GROUP BY "most_common_ipc_4_digit"
ORDER BY "occurrences" DESC NULLS LAST
LIMIT 1;