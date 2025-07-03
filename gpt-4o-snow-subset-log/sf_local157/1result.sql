WITH converted_volume AS (
    SELECT 
        "ticker",
        "market_date",
        CASE 
            WHEN "volume" = '-' THEN 0 
            WHEN RIGHT("volume", 1) = 'K' THEN CAST(LEFT("volume", LENGTH("volume") - 1) AS FLOAT) * 1000 
            WHEN RIGHT("volume", 1) = 'M' THEN CAST(LEFT("volume", LENGTH("volume") - 1) AS FLOAT) * 1000000 
        END AS "numeric_volume"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
    WHERE "market_date" BETWEEN '01-08-2021' AND '10-08-2021'
),
filtered_volume AS (
    SELECT
        "ticker",
        "market_date",
        "numeric_volume"
    FROM converted_volume
    WHERE "numeric_volume" > 0
),
pct_change_volume AS (
    SELECT
        "ticker",
        "market_date",
        "numeric_volume",
        (("numeric_volume" - LAG("numeric_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date")) 
        / NULLIF(LAG("numeric_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date"), 0)) * 100 AS "volume_pct_change"
    FROM filtered_volume
)
SELECT 
    "ticker",
    "market_date",
    "volume_pct_change"
FROM pct_change_volume
ORDER BY "ticker", "market_date";