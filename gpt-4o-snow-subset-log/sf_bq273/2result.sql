WITH monthly_profits AS (
    SELECT 
        DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."delivered_at" / 1000000)) AS "delivery_month", 
        SUM(p."retail_price" - ii."cost") AS "total_profit"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii 
        ON oi."inventory_item_id" = ii."id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p 
        ON ii."product_id" = p."id"
    WHERE oi."status" = 'Complete'
      AND oi."created_at" >= 1660003200000000 -- August 1, 2022
      AND oi."created_at" <= 1704067199000000 -- November 30, 2023
      AND oi."user_id" IN (
          SELECT DISTINCT e."user_id" 
          FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."EVENTS" e 
          WHERE e."traffic_source" = 'Facebook'
      )
    GROUP BY DATE_TRUNC('MONTH', TO_TIMESTAMP(oi."delivered_at" / 1000000))
),
month_over_month_changes AS (
    SELECT 
        "delivery_month", 
        "total_profit", 
        "total_profit" - LAG("total_profit") OVER (ORDER BY "delivery_month") AS "profit_increase"
    FROM monthly_profits
)
SELECT "delivery_month", "profit_increase" 
FROM month_over_month_changes
ORDER BY "profit_increase" DESC NULLS LAST 
LIMIT 5;