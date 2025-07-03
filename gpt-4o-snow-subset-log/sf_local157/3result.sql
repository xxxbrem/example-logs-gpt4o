WITH ConvertedVolume AS (
    -- Convert the "volume" column into numeric format
    SELECT 
        "ticker",
        "market_date",
        CASE 
            WHEN "volume" ILIKE '%K' THEN CAST(REPLACE("volume", 'K', '') AS FLOAT) * 1000
            WHEN "volume" ILIKE '%M' THEN CAST(REPLACE("volume", 'M', '') AS FLOAT) * 1000000
            WHEN "volume" = '-' THEN 0
            ELSE CAST("volume" AS FLOAT) 
        END AS "converted_volume"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
    WHERE "market_date" >= '01-08-2021' AND "market_date" <= '10-08-2021'
),
FilteredVolume AS (
    -- Eliminate records where "converted_volume" is zero
    SELECT 
        "ticker",
        TO_DATE("market_date", 'DD-MM-YYYY') AS "market_date", -- Convert date to proper format for calculations
        "converted_volume"
    FROM ConvertedVolume
    WHERE "converted_volume" > 0
),
DailyChange AS (
    -- Calculate daily percentage change in volume
    SELECT 
        t1."ticker",
        t1."market_date",
        t1."converted_volume" AS "current_volume",
        t2."converted_volume" AS "previous_volume",
        CASE 
            WHEN t2."converted_volume" IS NOT NULL THEN 
                ((t1."converted_volume" - t2."converted_volume") / t2."converted_volume") * 100
            ELSE NULL
        END AS "volume_percentage_change"
    FROM FilteredVolume t1
    LEFT JOIN FilteredVolume t2
        ON t1."ticker" = t2."ticker" AND t1."market_date" = t2."market_date" + INTERVAL '1 DAY'
)
SELECT 
    "ticker",
    TO_CHAR("market_date", 'DD-MM-YYYY') AS "market_date", -- Convert date back to original format
    ROUND("volume_percentage_change", 4) AS "volume_percentage_change"
FROM DailyChange
WHERE "volume_percentage_change" IS NOT NULL
ORDER BY "ticker", "market_date";