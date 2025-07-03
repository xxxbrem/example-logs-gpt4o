WITH MonthlyProfits AS (
    SELECT 
        DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."delivered_at" / 1000000)) AS "delivery_month", 
        SUM(oi."sale_price" - COALESCE(i."cost", 0)) AS "monthly_profit"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o 
        ON oi."order_id" = o."order_id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u 
        ON o."user_id" = u."id"
    LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" i 
        ON oi."inventory_item_id" = i."id"
    WHERE o."status" = 'Complete'
      AND u."traffic_source" ILIKE '%Facebook%'
      AND o."created_at" BETWEEN 1660000000000000 AND 1704124800000000 -- Filter for the time range (August 2022 to November 2023)
      AND oi."delivered_at" IS NOT NULL -- Include only delivered items
    GROUP BY "delivery_month"
)
SELECT 
    "delivery_month", 
    "monthly_profit",
    "monthly_profit" - LAG("monthly_profit") OVER (ORDER BY "delivery_month") AS "month_over_month_increase" 
FROM MonthlyProfits
ORDER BY "month_over_month_increase" DESC NULLS LAST -- Sort by largest month-over-month increase, ignoring NULLs
LIMIT 5; -- Return the top 5 months with the highest increases