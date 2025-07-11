SELECT 
    f.value::VARIANT:"item_name"::STRING AS "Item_Name", 
    SUM(f.value::VARIANT:"quantity"::NUMBER) AS "Total_Quantity"
FROM (
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201204"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201207"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201208"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201211"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201212"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201213"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201214"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201215"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201216"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201217"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201218"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201219"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201220"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201221"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201222"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201223"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201224"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201225"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201226"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201227"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201228"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201229"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201230"
    UNION ALL
    SELECT * 
    FROM "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201231"
) t, 
LATERAL FLATTEN(input => t."ITEMS") f
WHERE 
    t."ITEMS" ILIKE '%Google%Navy%Speckled%Tee%'
    AND f.value::VARIANT:"item_name"::STRING IS NOT NULL
GROUP BY 
    f.value::VARIANT:"item_name"::STRING
ORDER BY 
    "Total_Quantity" DESC NULLS LAST
LIMIT 1;