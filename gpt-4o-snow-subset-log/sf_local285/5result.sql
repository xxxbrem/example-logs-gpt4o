WITH 
-- Calculate wholesale price statistics
Wholesale_Stats AS (
    SELECT YEAR(DATE(w."whsle_date")) AS "whsle_year",
           wc."category_name",
           ROUND(AVG(w."whsle_px_rmb-kg"), 2) AS "avg_whsle_price",
           ROUND(MAX(w."whsle_px_rmb-kg"), 2) AS "max_whsle_price",
           ROUND(MIN(w."whsle_px_rmb-kg"), 2) AS "min_whsle_price",
           ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) AS "whsle_price_diff",
           ROUND(SUM(w."whsle_px_rmb-kg"), 2) AS "total_whsle_price_rmb"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT wc
    ON w."item_code" = wc."item_code"
    WHERE DATE(w."whsle_date") BETWEEN '2020-01-01' AND '2023-12-31'
    GROUP BY "whsle_year", wc."category_name"
),
-- Calculate total selling price, total loss and profit
Financial_Stats AS (
    SELECT YEAR(DATE(t."txn_date")) AS "txn_year",
           wc."category_name",
           ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg"), 2) AS "total_selling_price_rmb",
           ROUND(SUM(t."qty_sold(kg)" * w."whsle_px_rmb-kg"), 2) AS "total_whsle_price_rmb",
           ROUND(SUM(t."qty_sold(kg)" * w."whsle_px_rmb-kg" * lr."loss_rate_%" / 100), 2) AS "total_loss_rmb",
           ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg") 
               - SUM(t."qty_sold(kg)" * w."whsle_px_rmb-kg") 
               - SUM(t."qty_sold(kg)" * w."whsle_px_rmb-kg" * lr."loss_rate_%" / 100), 2) AS "profit_rmb",
           ROUND(AVG(lr."loss_rate_%"), 2) AS "avg_loss_rate_%"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_TXN_DF t
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_CAT wc 
    ON t."item_code" = wc."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_WHSLE_DF w 
    ON t."item_code" = w."item_code"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.VEG_LOSS_RATE_DF lr
    ON t."item_code" = lr."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY "txn_year", wc."category_name"
)
-- Combine data from both CTEs
SELECT ws."whsle_year",
       ws."category_name",
       ws."avg_whsle_price",
       ws."max_whsle_price",
       ws."min_whsle_price",
       ws."whsle_price_diff",
       ws."total_whsle_price_rmb",
       fs."total_selling_price_rmb",
       fs."avg_loss_rate_%",
       fs."total_loss_rmb",
       fs."profit_rmb"
FROM Wholesale_Stats ws
LEFT JOIN Financial_Stats fs
ON ws."whsle_year" = fs."txn_year" AND ws."category_name" = fs."category_name"
ORDER BY ws."whsle_year", ws."category_name"
LIMIT 100;