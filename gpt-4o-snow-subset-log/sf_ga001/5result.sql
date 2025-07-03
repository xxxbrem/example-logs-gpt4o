SELECT 
    f2.value::VARIANT:"item_name"::STRING AS "Other Product", 
    SUM(f2.value::VARIANT:"quantity"::NUMBER) AS "Total Quantity"
FROM (
    SELECT "ITEMS"
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201201" t, 
    LATERAL FLATTEN(input => t."ITEMS") f1
    WHERE f1.value::VARIANT:"item_name"::STRING ILIKE '%Google%Navy%Speckled%Tee%'
) transactions,
LATERAL FLATTEN(input => transactions."ITEMS") f2
WHERE f2.value::VARIANT:"item_name"::STRING NOT ILIKE '%Google%Navy%Speckled%Tee%'
GROUP BY f2.value::VARIANT:"item_name"::STRING
ORDER BY "Total Quantity" DESC NULLS LAST
LIMIT 1;