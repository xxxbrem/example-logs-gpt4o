WITH Initial_Prices AS (
    SELECT "TICKER", "DATE", "VALUE" AS "INITIAL_PRICE"
    FROM (
        SELECT "TICKER", "DATE", "VALUE",
               ROW_NUMBER() OVER (PARTITION BY "TICKER" ORDER BY "DATE" ASC) AS "ROW_NUM"
        FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES"
        WHERE "VARIABLE_NAME" = 'Post-Market Close'
          AND "TICKER" IN ('AAPL', 'AMZN', 'GOOG', 'MSFT', 'NVDA', 'TSLA', 'META')
          AND "DATE" >= '2024-01-01'
    )
    WHERE "ROW_NUM" = 1
),
Final_Prices AS (
    SELECT "TICKER", "DATE", "VALUE" AS "FINAL_PRICE"
    FROM (
        SELECT "TICKER", "DATE", "VALUE",
               ROW_NUMBER() OVER (PARTITION BY "TICKER" ORDER BY "DATE" DESC) AS "ROW_NUM"
        FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES"
        WHERE "VARIABLE_NAME" = 'Post-Market Close'
          AND "TICKER" IN ('AAPL', 'AMZN', 'GOOG', 'MSFT', 'NVDA', 'TSLA', 'META')
          AND "DATE" <= '2024-06-30'
    )
    WHERE "ROW_NUM" = 1
)
SELECT 
    Initial_Prices."TICKER", 
    ((Final_Prices."FINAL_PRICE" - Initial_Prices."INITIAL_PRICE") / Initial_Prices."INITIAL_PRICE") * 100 AS "PERCENTAGE_CHANGE"
FROM Initial_Prices
JOIN Final_Prices
ON Initial_Prices."TICKER" = Final_Prices."TICKER";