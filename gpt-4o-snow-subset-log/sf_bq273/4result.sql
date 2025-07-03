WITH monthly_profit AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP(o."delivered_at" * 0.000001), 'YYYY-MM') AS "delivery_month",
        SUM(oi."sale_price" - i."cost") AS "monthly_profit"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    ON o."order_id" = oi."order_id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" i
    ON oi."product_id" = i."id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."EVENTS" e
    ON o."user_id" = e."user_id"
    WHERE o."status" = 'Complete'
    AND e."traffic_source" ILIKE '%facebook%'
    AND o."created_at" >= 1659312000000000 -- Timestamp for August 1, 2022
    AND o."created_at" <= 1701388800000000 -- Timestamp for November 30, 2023
    GROUP BY "delivery_month"
)
SELECT 
    mp1."delivery_month" AS "current_month",
    (mp1."monthly_profit" - COALESCE(mp2."monthly_profit", 0)) AS "profit_increase"
FROM monthly_profit mp1
LEFT JOIN monthly_profit mp2
ON mp1."delivery_month" = TO_CHAR(DATEADD(MONTH, 1, TO_DATE(mp2."delivery_month" || '-01')), 'YYYY-MM') 
-- Calculate the previous month's start date and convert back to "YYYY-MM" for matching
WHERE mp2."monthly_profit" IS NOT NULL -- Ensure the previous month has data for comparison
ORDER BY "profit_increase" DESC NULLS LAST -- Sort by largest profit increases, excluding NULLs
LIMIT 5; -- Return the top 5 months with the largest increases