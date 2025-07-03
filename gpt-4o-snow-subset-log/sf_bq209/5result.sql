SELECT 
    COUNT(*) AS "utility_patent_count"
FROM (
    SELECT 
        p."publication_number",
        COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) AS "forward_citation_count"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS p,
        LATERAL FLATTEN(input => p."citation") c
    WHERE 
        p."application_kind" = 'A' -- Utility patents
        AND p."grant_date" >= 20100101 
        AND p."grant_date" <= 20101231 -- Granted in 2010
        AND c.value::VARIANT:"filing_date"::NUMBER IS NOT NULL -- Forward citation with filing dates
        AND c.value::VARIANT:"filing_date"::NUMBER <= p."filing_date" + 10000 -- Within 10 years from the patent's filing date
    GROUP BY 
        p."publication_number"
    HAVING 
        COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) = 1 -- Exactly one forward citation
) AS filtered_patents;