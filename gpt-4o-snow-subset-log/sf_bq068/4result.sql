WITH credits AS (
  SELECT 
    f.value::STRING AS "address",
    o."type",
    SUM(o."value") AS "total_credits"
  FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS o,
    LATERAL FLATTEN(input => o."addresses") f
  WHERE o."block_number" IN (
    SELECT DISTINCT "block_number"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.TRANSACTIONS
    WHERE "block_timestamp" >= 1393632000000000 -- 2014-03-01 (start of March in microseconds)
      AND "block_timestamp" < 1396310400000000 -- 2014-04-01 (start of April in microseconds)
  )
  GROUP BY "address", "type"
),
debits AS (
  SELECT 
    f.value::STRING AS "address",
    i."type",
    SUM(i."value") AS "total_debits"
  FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS i,
    LATERAL FLATTEN(input => i."addresses") f
  WHERE i."block_number" IN (
    SELECT DISTINCT "block_number"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.TRANSACTIONS
    WHERE "block_timestamp" >= 1393632000000000 -- 2014-03-01 (start of March in microseconds)
      AND "block_timestamp" < 1396310400000000 -- 2014-04-01 (start of April in microseconds)
  )
  GROUP BY "address", "type"
),
balances AS (
  SELECT
    c."type",
    c."address",
    COALESCE(c."total_credits", 0) - COALESCE(d."total_debits", 0) AS "net_balance"
  FROM credits c
  LEFT JOIN debits d
    ON c."address" = d."address" AND c."type" = d."type"
)
SELECT 
  "type",
  MAX("net_balance") AS "maximum_balance",
  MIN("net_balance") AS "minimum_balance"
FROM balances
GROUP BY "type";