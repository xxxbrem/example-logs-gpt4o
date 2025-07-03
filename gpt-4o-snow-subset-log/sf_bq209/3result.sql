SELECT COUNT(*) AS "utility_patents_with_one_forward_citation"
FROM (
    SELECT 
        p."publication_number" AS "cited_patent",
        COUNT(DISTINCT c.value::VARIANT:"application_number"::TEXT) AS "forward_citation_count"
    FROM PATENTS.PATENTS.PUBLICATIONS p, 
         LATERAL FLATTEN(input => p."citation") c
    WHERE p."grant_date" >= 20100101 AND p."grant_date" < 20110101 
        AND p."application_kind" = 'U'
        AND c.value::VARIANT:"filing_date"::NUMBER >= p."filing_date"
        AND c.value::VARIANT:"filing_date"::NUMBER < p."filing_date" + 100000
    GROUP BY p."publication_number"
    HAVING COUNT(DISTINCT c.value::VARIANT:"application_number"::TEXT) = 1
);