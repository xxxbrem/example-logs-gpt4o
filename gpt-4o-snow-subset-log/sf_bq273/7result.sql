WITH Monthly_Profit AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP(oi."delivered_at"/1000000), 'YYYY-MM') AS "delivery_month",
        SUM(oi."sale_price" - p."cost") AS "profit"
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o 
      ON oi."order_id" = o."order_id"
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p 
      ON oi."product_id" = p."id"
    WHERE o."created_at" BETWEEN 1661990400000000 AND 1703980799000000 -- Time range from August 2022 to November 2023
      AND o."status" = 'Complete'
      AND o."user_id" IN (
          SELECT DISTINCT "user_id" 
          FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.EVENTS 
          WHERE "traffic_source" ILIKE '%Facebook%'
            AND "user_id" IS NOT NULL
      )
    GROUP BY TO_CHAR(TO_TIMESTAMP(oi."delivered_at"/1000000), 'YYYY-MM')
    ORDER BY "delivery_month"
),
Profit_Delta AS (
    SELECT 
        "delivery_month",
        "profit",
        LAG("profit") OVER (ORDER BY "delivery_month") AS "previous_month_profit",
        ("profit" - LAG("profit") OVER (ORDER BY "delivery_month")) AS "profit_increase"
    FROM Monthly_Profit
)
SELECT 
    "delivery_month",
    "profit_increase"
FROM Profit_Delta
WHERE "profit_increase" IS NOT NULL
ORDER BY "profit_increase" DESC NULLS LAST
LIMIT 5;