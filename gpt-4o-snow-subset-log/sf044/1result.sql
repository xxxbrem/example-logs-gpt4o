WITH 
-- Filter post-market close prices for the Magnificent 7 companies within the date range
FilteredPrices AS (
  SELECT sp."TICKER", sp."DATE", sp."VALUE" AS "POST_MARKET_CLOSE", ci."COMPANY_NAME"
  FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES" sp
  JOIN "FINANCE__ECONOMICS"."CYBERSYN"."COMPANY_INDEX" ci
    ON sp."TICKER" = ci."PRIMARY_TICKER"
  WHERE sp."VARIABLE" = 'post-market_close'
    AND sp."DATE" BETWEEN '2024-01-01' AND '2024-06-30'
    AND (ci."COMPANY_NAME" ILIKE '%Meta%' OR ci."COMPANY_NAME" ILIKE '%Apple%'
         OR ci."COMPANY_NAME" ILIKE '%Microsoft%' OR ci."COMPANY_NAME" ILIKE '%Amazon%'
         OR ci."COMPANY_NAME" ILIKE '%Tesla%' OR ci."COMPANY_NAME" ILIKE '%NVIDIA%'
         OR ci."COMPANY_NAME" ILIKE '%Alphabet%')
),
-- Get the earliest and latest prices for each company
EarliestLatestPrices AS (
  SELECT 
    "TICKER", 
    "COMPANY_NAME",
    FIRST_VALUE("POST_MARKET_CLOSE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" ASC) AS "EARLIEST_PRICE",
    FIRST_VALUE("POST_MARKET_CLOSE") OVER (PARTITION BY "TICKER" ORDER BY "DATE" DESC) AS "LATEST_PRICE"
  FROM FilteredPrices
),
-- Remove duplicates and ensure only necessary columns are retained
DistinctPrices AS (
  SELECT DISTINCT "TICKER", "COMPANY_NAME", "EARLIEST_PRICE", "LATEST_PRICE"
  FROM EarliestLatestPrices
),
-- Calculate percentage change for each company
PercentageChange AS (
  SELECT 
    "COMPANY_NAME",
    "TICKER",
    "EARLIEST_PRICE",
    "LATEST_PRICE",
    CASE 
      WHEN "EARLIEST_PRICE" IS NOT NULL AND "LATEST_PRICE" IS NOT NULL AND "EARLIEST_PRICE" <> 0 
      THEN (("LATEST_PRICE" - "EARLIEST_PRICE") / "EARLIEST_PRICE") * 100
      ELSE NULL
    END AS "PERCENTAGE_CHANGE"
  FROM DistinctPrices
)
-- Retrieve the results
SELECT 
  "COMPANY_NAME", 
  "TICKER", 
  "EARLIEST_PRICE",
  "LATEST_PRICE",
  "PERCENTAGE_CHANGE"
FROM PercentageChange
ORDER BY "PERCENTAGE_CHANGE" DESC NULLS LAST;