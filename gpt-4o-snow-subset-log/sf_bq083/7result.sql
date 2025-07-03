WITH MintData AS (
  -- Extract minting transactions
  SELECT 
    TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)::DATE AS "transaction_date",
    CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 75, 64), '0')) AS FLOAT) / 1000000 AS "market_value_change"
  FROM "CRYPTO"."CRYPTO_ETHEREUM"."TRANSACTIONS"
  WHERE "input" LIKE '0x40c10f19%'
    AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
    AND YEAR(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) = 2023
),
BurnData AS (
  -- Extract burning transactions
  SELECT 
    TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)::DATE AS "transaction_date",
    -1 * CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 11, 64), '0')) AS FLOAT) / 1000000 AS "market_value_change"
  FROM "CRYPTO"."CRYPTO_ETHEREUM"."TRANSACTIONS"
  WHERE "input" LIKE '0x42966c68%'
    AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
    AND YEAR(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) = 2023
),
DailyMarketValueChange AS (
  -- Combine minting and burning data, and aggregate daily market value changes
  SELECT 
    "transaction_date",
    SUM("market_value_change") AS "daily_market_value_change"
  FROM (
    SELECT * FROM MintData
    UNION ALL
    SELECT * FROM BurnData
  )
  GROUP BY "transaction_date"
)
-- Format the results as USD and sort in descending order
SELECT 
  "transaction_date",
  '$' || TO_CHAR("daily_market_value_change", 'FM999,999,999,999,999.00') AS "Δ Total Market Value"
FROM DailyMarketValueChange
ORDER BY "transaction_date" DESC NULLS LAST;