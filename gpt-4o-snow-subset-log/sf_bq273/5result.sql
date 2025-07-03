WITH MonthlyProfits AS (
    SELECT 
        DATE_PART('month', TO_TIMESTAMP("ORDER_ITEMS"."delivered_at" / 1000000)) AS "delivery_month",
        DATE_PART('year', TO_TIMESTAMP("ORDER_ITEMS"."delivered_at" / 1000000)) AS "delivery_year",
        SUM("ORDER_ITEMS"."sale_price") AS "total_sales",
        SUM("INVENTORY_ITEMS"."cost") AS "total_cost",
        SUM("ORDER_ITEMS"."sale_price") - SUM("INVENTORY_ITEMS"."cost") AS "profit"
    FROM 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS AS "ORDER_ITEMS"
    JOIN 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.INVENTORY_ITEMS AS "INVENTORY_ITEMS"
    ON 
        "ORDER_ITEMS"."inventory_item_id" = "INVENTORY_ITEMS"."id"
    JOIN 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS AS "USERS"
    ON 
        "ORDER_ITEMS"."user_id" = "USERS"."id"
    WHERE 
        "ORDER_ITEMS"."status" = 'Complete'
        AND "USERS"."traffic_source" = 'Facebook'
        AND TO_TIMESTAMP("ORDER_ITEMS"."created_at" / 1000000) >= '2022-08-01'
        AND TO_TIMESTAMP("ORDER_ITEMS"."created_at" / 1000000) < '2023-12-01'
    GROUP BY 
        DATE_PART('year', TO_TIMESTAMP("ORDER_ITEMS"."delivered_at" / 1000000)),
        DATE_PART('month', TO_TIMESTAMP("ORDER_ITEMS"."delivered_at" / 1000000))
),
MonthlyProfitChanges AS (
    SELECT
        "delivery_month",
        "delivery_year",
        "profit",
        "profit" - LAG("profit") OVER (ORDER BY "delivery_year", "delivery_month") AS "month_over_month_profit_change"
    FROM 
        MonthlyProfits
)
SELECT 
    "delivery_month",
    "delivery_year",
    "month_over_month_profit_change"
FROM 
    MonthlyProfitChanges
ORDER BY 
    "month_over_month_profit_change" DESC NULLS LAST
LIMIT 5;