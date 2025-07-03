WITH financial_performance AS (
    -- Aggregate wholesale metrics grouped by year and category
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP(wdf."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        vc."category_name",
        ROUND(AVG(wdf."whsle_px_rmb-kg"), 2) AS "average_wholesale_price",
        ROUND(MAX(wdf."whsle_px_rmb-kg"), 2) AS "maximum_wholesale_price",
        ROUND(MIN(wdf."whsle_px_rmb-kg"), 2) AS "minimum_wholesale_price",
        ROUND(MAX(wdf."whsle_px_rmb-kg") - MIN(wdf."whsle_px_rmb-kg"), 2) AS "wholesale_price_difference",
        ROUND(SUM(wdf."whsle_px_rmb-kg"), 2) AS "total_wholesale_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF wdf
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vc
    ON wdf."item_code" = vc."item_code"
    GROUP BY "year", vc."category_name"
),
loss_data AS (
    -- Calculate average loss rate and total loss grouped by year and category
    SELECT
        EXTRACT(YEAR FROM TO_TIMESTAMP(wdf."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        vc."category_name",
        ROUND(AVG(lr."loss_rate_%"), 2) AS "average_loss_rate",
        ROUND(SUM(wdf."whsle_px_rmb-kg" * lr."loss_rate_%" / 100), 2) AS "total_loss"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF lr
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF wdf
    ON lr."item_code" = wdf."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vc
    ON lr."item_code" = vc."item_code"
    GROUP BY "year", vc."category_name"
),
selling_data AS (
    -- Calculate total selling price grouped by year and category
    SELECT
        EXTRACT(YEAR FROM TO_TIMESTAMP(txn."txn_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        vc."category_name",
        ROUND(SUM(txn."qty_sold(kg)" * txn."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF txn
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vc
    ON txn."item_code" = vc."item_code"
    WHERE txn."sale/return" = 'sale'
    GROUP BY "year", vc."category_name"
)
-- Combine all the metrics into a final output
SELECT
    fp."year",
    fp."category_name",
    fp."average_wholesale_price",
    fp."maximum_wholesale_price",
    fp."minimum_wholesale_price",
    fp."wholesale_price_difference",
    fp."total_wholesale_price",
    sd."total_selling_price",
    ld."average_loss_rate",
    ld."total_loss",
    ROUND(sd."total_selling_price" - fp."total_wholesale_price" - ld."total_loss", 2) AS "profit"
FROM financial_performance fp
LEFT JOIN loss_data ld
ON fp."year" = ld."year" AND fp."category_name" = ld."category_name"
LEFT JOIN selling_data sd
ON fp."year" = sd."year" AND fp."category_name" = sd."category_name"
ORDER BY fp."year", fp."category_name";