SELECT COUNT(*)
FROM (
    SELECT "publication_number"
    FROM PATENTS.PATENTS.PUBLICATIONS t, LATERAL FLATTEN(input => t."citation") f
    WHERE t."grant_date" >= 20100101 AND t."grant_date" < 20110101
      AND t."application_kind" = 'U'
      AND f.value::VARIANT:"filing_date"::NUMBER >= t."filing_date"
      AND f.value::VARIANT:"filing_date"::NUMBER < t."filing_date" + 100000
    GROUP BY t."publication_number"
    HAVING COUNT(DISTINCT f.value::VARIANT:"application_number"::STRING) = 1
) subquery;