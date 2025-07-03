WITH 
-- Step 1: Aggregate wholesale data to calculate metrics like average price, max price, min price, price difference, and total wholesale price
wholesale_aggregated AS (
    SELECT 
        c."category_name",
        EXTRACT(YEAR FROM TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        AVG(w."whsle_px_rmb-kg") AS "average_wholesale_price",
        MAX(w."whsle_px_rmb-kg") AS "max_wholesale_price",
        MIN(w."whsle_px_rmb-kg") AS "min_wholesale_price",
        MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg") AS "wholesale_price_difference",
        SUM(w."whsle_px_rmb-kg") AS "total_wholesale_price"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_WHSLE_DF" AS w
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" AS c
    ON w."item_code" = c."item_code"
    GROUP BY c."category_name", EXTRACT(YEAR FROM TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS'))
),

-- Step 2: Aggregate transaction data to calculate the total selling price
transaction_aggregated AS (
    SELECT 
        c."category_name",
        EXTRACT(YEAR FROM TO_DATE(t."txn_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg") AS "total_selling_price"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_TXN_DF" AS t
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" AS c
    ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY c."category_name", EXTRACT(YEAR FROM TO_DATE(t."txn_date", 'YYYY-MM-DD HH24:MI:SS'))
),

-- Step 3: Aggregate loss rate data to calculate the average loss rate
loss_rate_aggregated AS (
    SELECT 
        c."category_name",
        EXTRACT(YEAR FROM TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        AVG(l."loss_rate_%") AS "average_loss_rate",
        SUM(w."whsle_px_rmb-kg" * l."loss_rate_%" / 100) AS "total_loss"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_LOSS_RATE_DF" AS l
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_WHSLE_DF" AS w
    ON l."item_code" = w."item_code"
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" AS c
    ON l."item_code" = c."item_code"
    GROUP BY c."category_name", EXTRACT(YEAR FROM TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS'))
)

-- Step 4: Combine all aggregated data and calculate profit
SELECT 
    w."category_name",
    w."year",
    ROUND(w."average_wholesale_price", 2) AS "average_wholesale_price",
    ROUND(w."max_wholesale_price", 2) AS "max_wholesale_price",
    ROUND(w."min_wholesale_price", 2) AS "min_wholesale_price",
    ROUND(w."wholesale_price_difference", 2) AS "wholesale_price_difference",
    ROUND(w."total_wholesale_price", 2) AS "total_wholesale_price",
    ROUND(t."total_selling_price", 2) AS "total_selling_price",
    ROUND(l."average_loss_rate", 2) AS "average_loss_rate",
    ROUND(l."total_loss", 2) AS "total_loss",
    ROUND(t."total_selling_price" - w."total_wholesale_price" - l."total_loss", 2) AS "profit"
FROM wholesale_aggregated AS w
LEFT JOIN transaction_aggregated AS t
    ON w."category_name" = t."category_name" AND w."year" = t."year"
LEFT JOIN loss_rate_aggregated AS l
    ON w."category_name" = l."category_name" AND w."year" = l."year"
ORDER BY w."category_name", w."year"
LIMIT 100;