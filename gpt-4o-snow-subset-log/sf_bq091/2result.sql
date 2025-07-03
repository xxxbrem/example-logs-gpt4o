SELECT CAST("filing_date" / 10000 AS INT) AS "year", COUNT("family_id") AS "application_count"
FROM "PATENTS"."PATENTS"."PUBLICATIONS" t,
LATERAL FLATTEN(input => t."assignee_harmonized") f,
LATERAL FLATTEN(input => t."ipc") ipc_f
WHERE ipc_f.value::VARIANT:"code"::STRING ILIKE '%A61%' -- Filter patents in the 'A61' category
AND f.value::VARIANT:"name"::STRING = (
    SELECT f.value::VARIANT:"name"::STRING 
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" t,
    LATERAL FLATTEN(input => t."assignee_harmonized") f,
    LATERAL FLATTEN(input => t."ipc") ipc_f
    WHERE ipc_f.value::VARIANT:"code"::STRING ILIKE '%A61%'
    GROUP BY f.value::VARIANT:"name"::STRING
    ORDER BY COUNT(DISTINCT t."family_id") DESC NULLS LAST
    LIMIT 1
) -- Match the top assignee
GROUP BY CAST("filing_date" / 10000 AS INT) -- Group by filing year
ORDER BY COUNT("family_id") DESC NULLS LAST
LIMIT 1;