WITH filtered_orders AS (
    -- Step 1: Filter "Complete" orders created between August 2022 and November 2023, sourced from Facebook
    SELECT 
        o."order_id",
        o."created_at",
        o."delivered_at",
        o."status",
        o."num_of_item",
        o."user_id",
        oi."inventory_item_id",
        oi."sale_price",
        i."cost",
        TO_CHAR(TO_TIMESTAMP(o."delivered_at" / 1000000), 'YYYY-MM') AS delivery_month
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u
        ON o."user_id" = u."id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
        ON o."order_id" = oi."order_id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" i
        ON oi."inventory_item_id" = i."id"
    WHERE u."traffic_source" ILIKE '%Facebook%' 
        AND o."status" = 'Complete' 
        AND o."created_at" BETWEEN 1659312000000000 AND 1701388800000000
),
monthly_profits AS (
    -- Step 2: Summarize profit (sales - cost) grouped by delivery month
    SELECT 
        delivery_month,
        SUM("sale_price" - "cost") AS total_profit
    FROM filtered_orders
    GROUP BY delivery_month
),
profit_growth AS (
    -- Step 3: Calculate month-over-month profit increase
    SELECT 
        delivery_month,
        total_profit,
        total_profit - LAG(total_profit) OVER (ORDER BY delivery_month) AS month_over_month_growth
    FROM monthly_profits
)
-- Step 4: Fetch top 5 months with highest month-over-month profit growth
SELECT 
    delivery_month,
    total_profit,
    month_over_month_growth
FROM profit_growth
ORDER BY month_over_month_growth DESC NULLS LAST
LIMIT 5;