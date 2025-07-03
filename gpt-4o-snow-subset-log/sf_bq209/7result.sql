SELECT COUNT(*)
FROM (
  SELECT 
    p."publication_number", 
    COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) AS forward_citation_count
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p, 
       LATERAL FLATTEN(input => p."citation") c
  WHERE p."application_kind" = 'U' -- Only utility patents
    AND p."grant_date" BETWEEN 20100101 AND 20101231 -- Patents granted in 2010
    AND c.value::VARIANT:"filing_date"::NUMBER <= p."filing_date" + 3652 -- Forward citations within 10 years of the patent filing date
  GROUP BY p."publication_number"
) subquery
WHERE subquery.forward_citation_count = 1; -- Exactly one forward citation within 10 years