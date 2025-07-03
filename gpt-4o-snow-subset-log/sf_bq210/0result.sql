SELECT COUNT(DISTINCT t."publication_number") AS "num_patents"
FROM "PATENTS"."PATENTS"."PUBLICATIONS" t, LATERAL FLATTEN(input => t."claims_localized") f
WHERE t."country_code" = 'US' 
  AND t."kind_code" = 'B2'
  AND t."grant_date" >= 20080101 
  AND t."grant_date" <= 20181231
  AND f.value::STRING NOT ILIKE '%claim%'
;