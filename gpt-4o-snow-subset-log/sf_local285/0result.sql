WITH CTE_WHSLE_STATS AS (
    SELECT 
        vcat."category_name",
        YEAR(TO_TIMESTAMP(whsle."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        ROUND(AVG(whsle."whsle_px_rmb-kg"), 2) AS "avg_wholesale_price",
        ROUND(MAX(whsle."whsle_px_rmb-kg"), 2) AS "max_wholesale_price",
        ROUND(MIN(whsle."whsle_px_rmb-kg"), 2) AS "min_wholesale_price",
        ROUND(MAX(whsle."whsle_px_rmb-kg") - MIN(whsle."whsle_px_rmb-kg"), 2) AS "wholesale_price_difference",
        ROUND(SUM(whsle."whsle_px_rmb-kg"), 2) AS "total_wholesale_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vcat
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF whsle
    ON vcat."item_code" = whsle."item_code"
    GROUP BY vcat."category_name", YEAR(TO_TIMESTAMP(whsle."whsle_date", 'YYYY-MM-DD HH24:MI:SS'))
),
CTE_SELLING_STATS AS (
    SELECT 
        vcat."category_name",
        YEAR(TO_TIMESTAMP(txn."txn_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        ROUND(SUM(txn."qty_sold(kg)" * txn."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF txn
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vcat
    ON txn."item_code" = vcat."item_code"
    WHERE txn."sale/return" = 'sale'
    GROUP BY vcat."category_name", YEAR(TO_TIMESTAMP(txn."txn_date", 'YYYY-MM-DD HH24:MI:SS'))
),
CTE_LOSS_STATS AS (
    SELECT 
        vcat."category_name",
        YEAR(TO_TIMESTAMP(whsle."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        ROUND(AVG(loss."loss_rate_%"), 2) AS "avg_loss_rate",
        ROUND(SUM(loss."loss_rate_%" * whsle."whsle_px_rmb-kg" / 100), 2) AS "total_loss_rmb"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT vcat
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF whsle
    ON vcat."item_code" = whsle."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF loss
    ON vcat."item_code" = loss."item_code"
    GROUP BY vcat."category_name", YEAR(TO_TIMESTAMP(whsle."whsle_date", 'YYYY-MM-DD HH24:MI:SS'))
)
SELECT 
    ws."category_name",
    ws."year",
    ws."avg_wholesale_price",
    ws."max_wholesale_price",
    ws."min_wholesale_price",
    ws."wholesale_price_difference",
    ws."total_wholesale_price",
    ss."total_selling_price",
    ls."avg_loss_rate",
    ls."total_loss_rmb",
    ROUND(ss."total_selling_price" - ws."total_wholesale_price" - ls."total_loss_rmb", 2) AS "profit"
FROM CTE_WHSLE_STATS ws
LEFT JOIN CTE_SELLING_STATS ss
ON ws."category_name" = ss."category_name" AND ws."year" = ss."year"
LEFT JOIN CTE_LOSS_STATS ls
ON ws."category_name" = ls."category_name" AND ws."year" = ls."year"
ORDER BY ws."category_name", ws."year";