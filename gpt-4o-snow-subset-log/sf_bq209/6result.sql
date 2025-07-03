SELECT COUNT(DISTINCT t."publication_number") AS "utility_patents_with_one_forward_citation"
FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."citation") f
WHERE t."grant_date" >= 20100101 
  AND t."grant_date" <= 20101231 
  AND t."application_kind" = 'U'
  AND f.value::VARIANT:"filing_date"::NUMBER <= (t."filing_date" + 100000) 
GROUP BY t."publication_number"
HAVING COUNT(DISTINCT f.value::VARIANT:"application_number"::STRING) = 1;