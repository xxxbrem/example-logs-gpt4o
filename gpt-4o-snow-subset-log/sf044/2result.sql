WITH Magnificent7 AS (
    -- List the Magnificent 7 tech companies and their tickers
    SELECT * FROM VALUES
        ('Apple Inc.', 'AAPL'),
        ('Microsoft Corp.', 'MSFT'),
        ('Alphabet Inc.', 'GOOGL'),
        ('Amazon.com Inc.', 'AMZN'),
        ('Meta Platforms Inc.', 'META'),
        ('Tesla Inc.', 'TSLA'),
        ('Nvidia Corp.', 'NVDA')
    AS Magnificent7("COMPANY_NAME", "TICKER")
),
FilteredData AS (
    -- Filter post-market close prices for the Magnificent 7 companies within the specified date range
    SELECT
        t."TICKER",
        t."VARIABLE_NAME",
        t."DATE",
        t."VALUE"
    FROM FINANCE__ECONOMICS.CYBERSYN.STOCK_PRICE_TIMESERIES t
    JOIN Magnificent7 m
    ON t."TICKER" = m."TICKER"
    WHERE t."VARIABLE_NAME" = 'Post-Market Close'
      AND t."DATE" BETWEEN '2024-01-01' AND '2024-06-30'
),
StartEndPrices AS (
    -- Extract the first (start) and last (end) post-market close prices for each ticker in the date range
    SELECT
        "TICKER",
        FIRST_VALUE("VALUE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" ASC) AS StartPrice,
        FIRST_VALUE("VALUE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" DESC) AS EndPrice
    FROM FilteredData
),
DistinctPrices AS (
    -- Remove duplicate rows to ensure unique ticker entries
    SELECT DISTINCT "TICKER", StartPrice, EndPrice
    FROM StartEndPrices
)
-- Calculate the percentage change for each company
SELECT
    m."COMPANY_NAME",
    d."TICKER",
    ROUND(((d.EndPrice - d.StartPrice) / d.StartPrice) * 100, 4) AS PercentageChange
FROM DistinctPrices d
JOIN Magnificent7 m
ON d."TICKER" = m."TICKER";