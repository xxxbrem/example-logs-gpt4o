SELECT COUNT(DISTINCT t."publication_number") AS total_non_claim_patents
FROM PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."claims_localized") f1
WHERE t."country_code" = 'US' 
  AND t."kind_code" = 'B2' 
  AND t."grant_date" BETWEEN 20080101 AND 20181231
  AND f1.value::VARIANT::STRING NOT ILIKE '%claim%';