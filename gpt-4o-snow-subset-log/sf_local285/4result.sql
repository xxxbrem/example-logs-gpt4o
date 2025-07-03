WITH 
-- Calculate wholesale data metrics
wholesale_data AS (
    SELECT 
        DATE_PART('YEAR', CAST(w."whsle_date" AS DATE)) AS "year",
        c."category_name",
        c."category_code",
        ROUND(AVG(w."whsle_px_rmb-kg"), 2) AS "average_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg"), 2) AS "maximum_wholesale_price",
        ROUND(MIN(w."whsle_px_rmb-kg"), 2) AS "minimum_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) AS "wholesale_price_difference",
        ROUND(SUM(w."whsle_px_rmb-kg"), 2) AS "total_wholesale_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON w."item_code" = c."item_code"
    GROUP BY "year", c."category_name", c."category_code"
),
-- Calculate selling price metrics
selling_data AS (
    SELECT 
        DATE_PART('YEAR', CAST(t."txn_date" AS DATE)) AS "year",
        c."category_name",
        c."category_code",
        ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF t
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY "year", c."category_name", c."category_code"
),
-- Calculate loss data metrics
loss_data AS (
    SELECT 
        DATE_PART('YEAR', CAST(w."whsle_date" AS DATE)) AS "year",
        c."category_name",
        c."category_code",
        ROUND(AVG(l."loss_rate_%"), 2) AS "average_loss_rate",
        ROUND(SUM(w."whsle_px_rmb-kg" * l."loss_rate_%" / 100), 2) AS "total_loss"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF l
    ON w."item_code" = l."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON w."item_code" = c."item_code"
    GROUP BY "year", c."category_name", c."category_code"
)
-- Combine all calculated metrics and compute profit
SELECT 
    ws."year",
    ws."category_name",
    ws."category_code",
    ws."average_wholesale_price",
    ws."maximum_wholesale_price",
    ws."minimum_wholesale_price",
    ws."wholesale_price_difference",
    ws."total_wholesale_price",
    sd."total_selling_price",
    ld."average_loss_rate",
    ld."total_loss",
    ROUND(sd."total_selling_price" - ws."total_wholesale_price" - ld."total_loss", 2) AS "profit"
FROM wholesale_data ws
LEFT JOIN selling_data sd
ON ws."year" = sd."year" AND ws."category_code" = sd."category_code"
LEFT JOIN loss_data ld
ON ws."year" = ld."year" AND ws."category_code" = ld."category_code"
ORDER BY ws."year", ws."category_name" ASC;