SELECT 
    CAST("filing_date" / 10000 AS INT) AS "filing_year", 
    COUNT("family_id") AS "application_count"
FROM 
    PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."cpc") f, 
    LATERAL FLATTEN(input => t."assignee_harmonized") ah
WHERE 
    f.value::VARIANT:"code"::STRING ILIKE 'A61%'  -- Filter CPC category 'A61'
    AND ah.value::VARIANT:"name"::STRING = (
        SELECT ah_sub.value::VARIANT:"name"::STRING  -- Subquery for dominant assignee
        FROM PATENTS.PATENTS.PUBLICATIONS t_sub, 
             LATERAL FLATTEN(input => t_sub."cpc") f_sub, 
             LATERAL FLATTEN(input => t_sub."assignee_harmonized") ah_sub
        WHERE f_sub.value::VARIANT:"code"::STRING ILIKE 'A61%'  -- Filter CPC 'A61'
        GROUP BY ah_sub.value::VARIANT:"name"::STRING
        ORDER BY COUNT(t_sub."family_id") DESC  -- Find top assignee by application count
        LIMIT 1
    )
GROUP BY 
    CAST("filing_date" / 10000 AS INT)  -- Group by filing year
ORDER BY 
    "application_count" DESC NULLS LAST -- Order by application count, excluding NULLs
LIMIT 1;