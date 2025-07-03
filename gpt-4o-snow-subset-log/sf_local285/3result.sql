WITH 
-- Step 1: Calculate average, maximum, minimum wholesale price, and wholesale price difference for each category and year
WholesaleStats AS (
    SELECT 
        YEAR(CAST(w."whsle_date" AS DATE)) AS "year",
        c."category_code",
        c."category_name",
        ROUND(AVG(w."whsle_px_rmb-kg"), 2) AS "avg_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg"), 2) AS "max_wholesale_price",
        ROUND(MIN(w."whsle_px_rmb-kg"), 2) AS "min_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) AS "wholesale_price_difference",
        ROUND(SUM(w."whsle_px_rmb-kg"), 2) AS "total_wholesale_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON w."item_code" = c."item_code"
    GROUP BY YEAR(CAST(w."whsle_date" AS DATE)), c."category_code", c."category_name"
),
-- Step 2: Calculate total selling price for each category and year
SellingData AS (
    SELECT 
        YEAR(CAST(t."txn_date" AS DATE)) AS "year",
        c."category_code",
        ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF t
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY YEAR(CAST(t."txn_date" AS DATE)), c."category_code"
),
-- Step 3: Calculate average loss rate and total loss for each category and year
LossData AS (
    SELECT 
        YEAR(CAST(t."txn_date" AS DATE)) AS "year",
        c."category_code",
        ROUND(AVG(l."loss_rate_%"), 2) AS "avg_loss_rate",
        ROUND(SUM(l."loss_rate_%" * t."qty_sold(kg)" * t."unit_selling_px_rmb/kg" / 100), 2) AS "total_loss"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF t
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF l
    ON t."item_code" = l."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY YEAR(CAST(t."txn_date" AS DATE)), c."category_code"
)
-- Step 4: Combine results and calculate profit
SELECT 
    w."year",
    w."category_code",
    w."category_name",
    w."avg_wholesale_price",
    w."max_wholesale_price",
    w."min_wholesale_price",
    w."wholesale_price_difference",
    w."total_wholesale_price",
    s."total_selling_price",
    l."avg_loss_rate",
    l."total_loss",
    ROUND(s."total_selling_price" - w."total_wholesale_price" - COALESCE(l."total_loss", 0), 2) AS "profit"
FROM WholesaleStats w
LEFT JOIN SellingData s
ON w."year" = s."year" AND w."category_code" = s."category_code"
LEFT JOIN LossData l
ON w."year" = l."year" AND w."category_code" = l."category_code"
ORDER BY w."year", w."category_code"
LIMIT 100;