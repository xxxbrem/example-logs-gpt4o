SELECT COUNT(*) AS "total_us_b2_patents_without_claim_word"
FROM PATENTS.PATENTS.PUBLICATIONS t, 
LATERAL FLATTEN(input => t."claims_localized") f 
WHERE "country_code" = 'US' AND "kind_code" = 'B2' 
  AND "grant_date" BETWEEN 20080101 AND 20181231 
  AND f.value::STRING NOT ILIKE '%claim%';