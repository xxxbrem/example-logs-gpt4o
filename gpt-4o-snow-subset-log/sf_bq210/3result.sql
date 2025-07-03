SELECT COUNT(1) AS "count_of_patents"
FROM (
    SELECT t."publication_number", f.value AS "claims_text"
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" t, LATERAL FLATTEN(input => t."claims_localized") f
    WHERE t."country_code" = 'US'
      AND t."kind_code" = 'B2'
      AND t."grant_date" >= 20080101
      AND t."grant_date" <= 20181231
) subquery
WHERE LOWER(subquery."claims_text") NOT LIKE '%claim%';