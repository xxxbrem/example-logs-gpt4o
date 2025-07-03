WITH monthly_facebook_profit AS (
    SELECT 
        DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."delivered_at"/1e6)) AS "delivery_month",
        SUM(oi."sale_price") - SUM(p."cost") AS "monthly_profit"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
        ON oi."user_id" = u."id"
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
        ON oi."product_id" = p."id"
    WHERE u."traffic_source" ILIKE '%Facebook%'
      AND oi."status" = 'Complete'
      AND oi."created_at" >= 1660000000000000  -- August 2022
      AND oi."created_at" <= 1709347199000000  -- November 2023
      AND oi."delivered_at" IS NOT NULL
    GROUP BY DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."delivered_at"/1e6))
),
monthly_increase AS (
    SELECT 
        "delivery_month",
        "monthly_profit",
        "monthly_profit" - LAG("monthly_profit") OVER (ORDER BY "delivery_month") AS "profit_increase"
    FROM monthly_facebook_profit
)
SELECT 
    "delivery_month", 
    "profit_increase"
FROM monthly_increase
ORDER BY "profit_increase" DESC NULLS LAST
LIMIT 5;