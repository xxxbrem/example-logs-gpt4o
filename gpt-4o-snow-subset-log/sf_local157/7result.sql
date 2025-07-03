WITH NormalizedVolumes AS (
    SELECT 
        "ticker", 
        "market_date", 
        CASE 
            WHEN "volume" ILIKE '%K%' THEN CAST(REPLACE("volume", 'K', '') AS FLOAT) * 1000
            WHEN "volume" ILIKE '%M%' THEN CAST(REPLACE("volume", 'M', '') AS FLOAT) * 1000000
            WHEN "volume" = '-' THEN 0
            ELSE CAST("volume" AS FLOAT)
        END AS "normalized_volume"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES" 
    WHERE "market_date" >= '01-08-2021' AND "market_date" <= '10-08-2021'
)
, PercentageChange AS (
    SELECT 
        "ticker",
        "market_date",
        "normalized_volume" AS "daily_volume",
        LAG("normalized_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date") AS "prev_day_volume",
        CASE 
            WHEN LAG("normalized_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date") = 0 THEN NULL
            ELSE ABS(("normalized_volume" - LAG("normalized_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date")) /
                     LAG("normalized_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date")) * 100
        END AS "percentage_change"
    FROM NormalizedVolumes
)
SELECT 
    "ticker", 
    "market_date", 
    "percentage_change"
FROM PercentageChange
WHERE "percentage_change" IS NOT NULL
ORDER BY "ticker", "market_date";