WITH Magnificent7 AS (
    SELECT DISTINCT "PRIMARY_TICKER", "COMPANY_NAME"
    FROM "FINANCE__ECONOMICS"."CYBERSYN"."COMPANY_INDEX"
    WHERE "PRIMARY_TICKER" IN ('AAPL', 'GOOG', 'AMZN', 'MSFT', 'META', 'NVDA', 'TSLA')
),
PostMarketPrice AS (
    SELECT "TICKER", "DATE", "VALUE"
    FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES"
    WHERE "VARIABLE_NAME" = 'Post-Market Close'
      AND "TICKER" IN ('AAPL', 'GOOG', 'AMZN', 'MSFT', 'META', 'NVDA', 'TSLA')
      AND "DATE" BETWEEN '2024-01-01' AND '2024-06-30'
),
PriceChanges AS (
    SELECT
        p."TICKER",
        MIN(p."VALUE") AS "Start_Price",
        MAX(p."VALUE") AS "End_Price",
        MAX(p."VALUE") - MIN(p."VALUE") AS "Absolute_Change",
        (MAX(p."VALUE") - MIN(p."VALUE")) / MIN(p."VALUE") * 100 AS "Percentage_Change"
    FROM PostMarketPrice p
    GROUP BY p."TICKER"
)
SELECT
    m."COMPANY_NAME",
    m."PRIMARY_TICKER" AS "TICKER",
    pc."Start_Price",
    pc."End_Price",
    pc."Absolute_Change",
    pc."Percentage_Change"
FROM PriceChanges pc
JOIN Magnificent7 m
  ON pc."TICKER" = m."PRIMARY_TICKER"
ORDER BY pc."Percentage_Change" DESC;