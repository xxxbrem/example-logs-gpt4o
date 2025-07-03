WITH formatted_volumes AS (
    SELECT 
        "ticker",
        "market_date",
        "price",
        CASE
            WHEN "volume" ILIKE '%K' THEN CAST(REPLACE("volume", 'K', '') AS FLOAT) * 1000
            WHEN "volume" ILIKE '%M' THEN CAST(REPLACE("volume", 'M', '') AS FLOAT) * 1000000
            WHEN "volume" = '-' THEN 0
            ELSE CAST("volume" AS FLOAT)
        END AS "numeric_volume"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
    WHERE "market_date" BETWEEN '01-08-2021' AND '10-08-2021'
),
non_zero_volumes AS (
    SELECT 
        "ticker",
        "market_date",
        "price",
        "numeric_volume",
        LAG("numeric_volume") OVER (PARTITION BY "ticker" ORDER BY TO_DATE("market_date", 'DD-MM-YYYY')) AS "prev_numeric_volume"
    FROM formatted_volumes
),
percentage_changes AS (
    SELECT 
        "ticker",
        "market_date",
        "price",
        "numeric_volume",
        "prev_numeric_volume",
        CASE
            WHEN "prev_numeric_volume" > 0 THEN ROUND((("numeric_volume" - "prev_numeric_volume") / "prev_numeric_volume") * 100, 4)
            ELSE NULL
        END AS "volume_percentage_change"
    FROM non_zero_volumes
)
SELECT 
    "ticker",
    "market_date",
    "numeric_volume",
    "prev_numeric_volume",
    "volume_percentage_change"
FROM percentage_changes
ORDER BY "ticker", TO_DATE("market_date", 'DD-MM-YYYY');