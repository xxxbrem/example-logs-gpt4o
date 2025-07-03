WITH TRANSACTIONS_ON_DATE AS (
  SELECT 
    "from_address", 
    "to_address", 
    "value", 
    "gas_price", 
    "gas", 
    "receipt_status", 
    "block_number",
    ("gas" * "gas_price") AS "total_gas_fee",
    "block_timestamp"
  FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
  WHERE DATE_FROM_PARTS(YEAR(CAST("block_timestamp" / 1e6 AS TIMESTAMP_NTZ)), 
                        MONTH(CAST("block_timestamp" / 1e6 AS TIMESTAMP_NTZ)), 
                        DAY(CAST("block_timestamp" / 1e6 AS TIMESTAMP_NTZ))) = '2016-10-14'
    AND "receipt_status" = 1
),
DEBITS_CREDITS AS (
  SELECT 
    "from_address" AS "address",
    -SUM(CAST("value" AS DOUBLE)) - SUM("total_gas_fee") AS "net_balance_change"
  FROM TRANSACTIONS_ON_DATE
  GROUP BY "from_address"
  UNION ALL
  SELECT 
    "to_address" AS "address",
    SUM(CAST("value" AS DOUBLE)) AS "net_balance_change"
  FROM TRANSACTIONS_ON_DATE
  GROUP BY "to_address"
),
AGGREGATED_BALANCES AS (
  SELECT 
    "address",
    SUM("net_balance_change") AS "total_net_balance_change"
  FROM DEBITS_CREDITS
  GROUP BY "address"
)
SELECT 
  MAX("total_net_balance_change") AS "maximum_net_balance_change",
  MIN("total_net_balance_change") AS "minimum_net_balance_change"
FROM AGGREGATED_BALANCES;