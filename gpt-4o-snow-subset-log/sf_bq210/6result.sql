SELECT COUNT(*) AS "patents_without_claim_keyword" 
FROM "PATENTS"."PATENTS"."PUBLICATIONS" 
WHERE "country_code" = 'US' 
  AND "grant_date" BETWEEN 20080101 AND 20181231 
  AND "kind_code" = 'B2' 
  AND "claims_localized"::TEXT NOT ILIKE '%claim%';