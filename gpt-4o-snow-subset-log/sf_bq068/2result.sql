WITH outputs AS (
  SELECT 
    o."type", 
    o."addresses", 
    SUM(o."value") AS "total_credit"
  FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS o
  WHERE o."block_timestamp" >= 1393632000000000 -- Start of March 2014 in microseconds
    AND o."block_timestamp" < 1396310400000000 -- Start of April 2014 in microseconds
  GROUP BY o."type", o."addresses"
),
inputs AS (
  SELECT 
    i."type", 
    i."addresses", 
    SUM(i."value") AS "total_debit"
  FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS i
  WHERE i."block_timestamp" >= 1393632000000000 -- Start of March 2014 in microseconds
    AND i."block_timestamp" < 1396310400000000 -- Start of April 2014 in microseconds
  GROUP BY i."type", i."addresses"
),
balances AS (
  SELECT 
    o."type", 
    o."addresses", 
    COALESCE(o."total_credit", 0) - COALESCE(i."total_debit", 0) AS "final_balance"
  FROM outputs o
  FULL OUTER JOIN inputs i 
    ON o."addresses" = i."addresses" 
    AND o."type" = i."type"
)
SELECT 
  b."type", 
  MAX(b."final_balance") AS "max_balance", 
  MIN(b."final_balance") AS "min_balance"
FROM balances b
GROUP BY b."type"
ORDER BY b."type";