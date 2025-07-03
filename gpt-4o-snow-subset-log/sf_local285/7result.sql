WITH wholesale_data AS (
    SELECT 
        TO_CHAR(TO_DATE(w."whsle_date"), 'YYYY') AS "year",
        c."category_name",
        ROUND(AVG(w."whsle_px_rmb-kg"), 2) AS "average_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg"), 2) AS "max_wholesale_price",
        ROUND(MIN(w."whsle_px_rmb-kg"), 2) AS "min_wholesale_price",
        ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) AS "wholesale_price_difference",
        ROUND(SUM(w."whsle_px_rmb-kg"), 2) AS "total_wholesale_price"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_WHSLE_DF" w
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" c 
        ON w."item_code" = c."item_code"
    GROUP BY 1, 2
),
selling_data AS (
    SELECT 
        TO_CHAR(TO_DATE(t."txn_date"), 'YYYY') AS "year",
        c."category_name",
        ROUND(SUM(t."qty_sold(kg)" * t."unit_selling_px_rmb/kg"), 2) AS "total_selling_price"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_TXN_DF" t
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" c
        ON t."item_code" = c."item_code"
    WHERE t."sale/return" = 'sale'
    GROUP BY 1, 2
),
loss_data AS (
    SELECT 
        c."category_name",
        TO_CHAR(TO_DATE(w."whsle_date"), 'YYYY') AS "year",
        ROUND(AVG(l."loss_rate_%"), 2) AS "average_loss_rate",
        ROUND(SUM(w."whsle_px_rmb-kg" * l."loss_rate_%" / 100), 2) AS "total_loss"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_WHSLE_DF" w
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_LOSS_RATE_DF" l
        ON w."item_code" = l."item_code"
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" c
        ON w."item_code" = c."item_code"
    GROUP BY 1, 2
)
SELECT 
    w."year",
    w."category_name",
    w."average_wholesale_price",
    w."max_wholesale_price",
    w."min_wholesale_price",
    w."wholesale_price_difference",
    w."total_wholesale_price",
    s."total_selling_price",
    l."average_loss_rate",
    l."total_loss",
    ROUND(s."total_selling_price" - w."total_wholesale_price", 2) AS "profit"
FROM wholesale_data w
LEFT JOIN selling_data s
    ON w."year" = s."year" AND w."category_name" = s."category_name"
LEFT JOIN loss_data l
    ON w."year" = l."year" AND w."category_name" = l."category_name"
ORDER BY 1, 2
LIMIT 100;