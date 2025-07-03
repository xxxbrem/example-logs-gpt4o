WITH AvgPrices AS (
    SELECT 
        YEAR(TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        c."category_name",
        ROUND(AVG(w."whsle_px_rmb-kg"), 2) AS "avg_whsle_price",
        ROUND(MAX(w."whsle_px_rmb-kg"), 2) AS "max_whsle_price",
        ROUND(MIN(w."whsle_px_rmb-kg"), 2) AS "min_whsle_price",
        ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) AS "whsle_price_difference",
        ROUND(SUM(w."whsle_px_rmb-kg"), 2) AS "total_whsle_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON w."item_code" = c."item_code"
    GROUP BY "year", c."category_name"
),
SellingPrices AS (
    SELECT 
        YEAR(TO_DATE(t."txn_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        c."category_name",
        ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF t
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY "year", c."category_name"
),
LossRates AS (
    SELECT 
        YEAR(TO_DATE(w."whsle_date", 'YYYY-MM-DD HH24:MI:SS')) AS "year",
        c."category_name",
        ROUND(AVG(l."loss_rate_%"), 2) AS "avg_loss_rate"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF l
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT c
    ON l."item_code" = c."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    ON w."item_code" = l."item_code"
    GROUP BY "year", c."category_name"
),
TotalLoss AS (
    SELECT 
        a."year",
        a."category_name",
        ROUND(a."total_whsle_price" * (l."avg_loss_rate" / 100), 2) AS "total_loss"
    FROM AvgPrices a
    JOIN LossRates l
    ON a."year" = l."year" AND a."category_name" = l."category_name"
)
SELECT 
    a."year",
    a."category_name",
    a."avg_whsle_price",
    a."max_whsle_price",
    a."min_whsle_price",
    a."whsle_price_difference",
    a."total_whsle_price",
    s."total_selling_price",
    l."avg_loss_rate",
    t."total_loss",
    ROUND(s."total_selling_price" - a."total_whsle_price" - t."total_loss", 2) AS "profit"
FROM AvgPrices a
JOIN SellingPrices s
ON a."year" = s."year" AND a."category_name" = s."category_name"
JOIN LossRates l
ON a."year" = l."year" AND a."category_name" = l."category_name"
JOIN TotalLoss t
ON a."year" = t."year" AND a."category_name" = t."category_name"
ORDER BY a."year", a."category_name"
LIMIT 50;