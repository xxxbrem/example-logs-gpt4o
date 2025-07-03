WITH Purchases AS (
    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201204" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'
    
    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201207" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201211" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201220" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201223" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201227" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201228" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'

    UNION ALL

    SELECT 
        t."ECOMMERCE"::VARIANT:"transaction_id" AS "transaction_id",
        f.VALUE AS "item"
    FROM 
        "GA4"."GA4_OBFUSCATED_SAMPLE_ECOMMERCE"."EVENTS_20201231" t,
        TABLE(FLATTEN(INPUT => t."ITEMS")) f
    WHERE 
        t."EVENT_NAME" ILIKE '%purchase%'
),
FilteredItems AS (
    SELECT 
        "transaction_id", 
        "item"::VARIANT:"item_name"::STRING AS "item_name", 
        "item"::VARIANT:"quantity"::NUMBER AS "quantity"
    FROM Purchases
),
TargetTransactions AS (
    SELECT DISTINCT "transaction_id"
    FROM FilteredItems
    WHERE "item_name" = 'Google Navy Speckled Tee'
),
RelatedItems AS (
    SELECT 
        i."item_name", 
        SUM(i."quantity") AS "total_quantity"
    FROM FilteredItems i
    JOIN TargetTransactions t
    ON i."transaction_id" = t."transaction_id"
    WHERE i."item_name" <> 'Google Navy Speckled Tee'
    GROUP BY i."item_name"
)
SELECT 
    "item_name", 
    "total_quantity"
FROM RelatedItems
ORDER BY "total_quantity" DESC NULLS LAST
LIMIT 1;