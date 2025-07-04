/*  What other product was most frequently bought together with
    “Google Navy Speckled Tee” in December-2020 purchases?           */

WITH dec_purchases AS (   -- every 2020-12 purchase event
    SELECT *
    FROM (
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201201" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201202" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201203" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201204" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201205" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201206" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201207" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201208" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201209" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201210" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201211" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201212" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201213" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201214" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201215" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201216" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201217" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201218" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201219" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201220" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201221" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201222" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201223" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201224" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201225" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201226" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201227" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201228" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201229" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201230" UNION ALL
        SELECT * FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE."EVENTS_20201231"
    )
    WHERE "EVENT_NAME" = 'purchase'
),

events_with_tee AS (      -- keep only purchases containing the Tee
    SELECT p.*
    FROM dec_purchases      AS p,
         LATERAL FLATTEN(INPUT => p."ITEMS") AS f
    WHERE LOWER(f.value:"item_name"::string) = 'google navy speckled tee'
)

SELECT
    other.value:"item_name"::string       AS "OTHER_PRODUCT",
    SUM( COALESCE( other.value:"quantity"::number , 1) ) AS "TOTAL_QUANTITY"
FROM events_with_tee               e,
     LATERAL FLATTEN(INPUT => e."ITEMS") AS other
WHERE LOWER(other.value:"item_name"::string) <> 'google navy speckled tee'
GROUP BY "OTHER_PRODUCT"
ORDER BY "TOTAL_QUANTITY" DESC NULLS LAST
LIMIT 1;