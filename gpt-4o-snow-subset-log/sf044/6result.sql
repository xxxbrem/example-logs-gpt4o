WITH StartPrices AS (
    SELECT 
        "TICKER", 
        "DATE", 
        "VALUE" AS "START_PRICE"
    FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES"
    WHERE "VARIABLE" = 'post-market_close'
      AND "DATE" >= '2024-01-01'
      AND "DATE" <= '2024-01-15' -- Allowing a buffer in case the exact start date has no data
      AND "TICKER" IN ('AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'NVDA', 'TSLA')
),
EndPrices AS (
    SELECT 
        "TICKER", 
        "DATE", 
        "VALUE" AS "END_PRICE"
    FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES"
    WHERE "VARIABLE" = 'post-market_close'
      AND "DATE" >= '2024-06-15'
      AND "DATE" <= '2024-06-30' -- Allowing a buffer in case the exact end date has no data
      AND "TICKER" IN ('AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'NVDA', 'TSLA')
),
StartPricesFiltered AS (
    SELECT 
        "TICKER", 
        FIRST_VALUE("START_PRICE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" ASC) AS "START_PRICE"
    FROM StartPrices
),
EndPricesFiltered AS (
    SELECT 
        "TICKER", 
        FIRST_VALUE("END_PRICE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" DESC) AS "END_PRICE"
    FROM EndPrices
)
SELECT 
    S."TICKER",
    ((E."END_PRICE" - S."START_PRICE") / S."START_PRICE") * 100 AS "PERCENTAGE_CHANGE"
FROM StartPricesFiltered S
JOIN EndPricesFiltered E
ON S."TICKER" = E."TICKER";