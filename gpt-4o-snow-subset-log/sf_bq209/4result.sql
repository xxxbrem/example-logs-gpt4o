SELECT COUNT(*) AS "total_patents_with_one_citation"
FROM (
    SELECT p."publication_number"
    FROM PATENTS.PATENTS.PUBLICATIONS p,
    LATERAL FLATTEN(input => p."citation") c
    WHERE p."grant_date" >= 20100101 AND p."grant_date" < 20110101
      AND p."application_kind" = 'A'
      AND c.value::VARIANT:"filing_date"::NUMBER <= (p."filing_date" + 3650)
    GROUP BY p."publication_number"
    HAVING COUNT(DISTINCT c.value::VARIANT:"application_number"::STRING) = 1
) result;