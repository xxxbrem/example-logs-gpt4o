WITH converted_volume AS (
    SELECT 
        "ticker", 
        TO_DATE("market_date", 'DD-MM-YYYY') AS "market_date", 
        CASE 
            WHEN "volume" ILIKE '%K%' THEN CAST(REPLACE("volume", 'K', '') AS FLOAT) * 1000 
            WHEN "volume" ILIKE '%M%' THEN CAST(REPLACE("volume", 'M', '') AS FLOAT) * 1000000 
            WHEN "volume" = '-' THEN 0.0 
            ELSE CAST("volume" AS FLOAT) 
        END AS "numeric_volume" 
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.BITCOIN_PRICES 
    WHERE "market_date" BETWEEN '01-08-2021' AND '10-08-2021'
),
non_zero_volume AS (
    SELECT 
        "ticker", 
        "market_date", 
        "numeric_volume", 
        LAG("numeric_volume") OVER (PARTITION BY "ticker" ORDER BY "market_date") AS "previous_volume"
    FROM converted_volume
    WHERE "numeric_volume" > 0
)
SELECT 
    "ticker", 
    TO_CHAR("market_date", 'DD-MM-YYYY') AS "market_date", 
    "numeric_volume", 
    "previous_volume", 
    CASE 
        WHEN "previous_volume" > 0 THEN ABS((("numeric_volume" - "previous_volume") / "previous_volume") * 100) 
        ELSE NULL 
    END AS "volume_percentage_change"
FROM non_zero_volume
ORDER BY "ticker", "market_date";