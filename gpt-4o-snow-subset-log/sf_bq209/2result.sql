SELECT COUNT(*) AS "utility_patents_with_one_forward_citation"
FROM (
    SELECT 
        t."publication_number", 
        COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) AS "forward_citation_count"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."citation") c
    WHERE 
        t."application_kind" = 'U' 
        AND t."grant_date" >= 20100101 
        AND t."grant_date" <= 20101231
        AND t."filing_date" IS NOT NULL
        AND c.value::VARIANT:"filing_date" IS NOT NULL
        AND (t."filing_date"::NUMBER + (10 * 365)) >= c.value::VARIANT:"filing_date"::NUMBER
    GROUP BY 
        t."publication_number"
    HAVING 
        COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) = 1
) subquery;