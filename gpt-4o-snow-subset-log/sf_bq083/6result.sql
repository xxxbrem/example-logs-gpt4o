WITH parsed_transactions AS (
  SELECT 
    "block_timestamp",
    CASE 
      WHEN "input" LIKE '0x40c10f19%' THEN 'mint'
      WHEN "input" LIKE '0x42966c68%' THEN 'burn'
    END AS operation,
    CAST(
      CONCAT(
        '0x',
        LTRIM(
          SUBSTRING(
            "input",
            CASE WHEN "input" LIKE '0x40c10f19%' THEN 75 ELSE 11 END,
            64
          ),
          '0'
        )
      ) AS FLOAT
    ) / 1000000 AS amount_in_millions
  FROM "CRYPTO"."CRYPTO_ETHEREUM"."TRANSACTIONS"
  WHERE 
    "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' 
    AND ("input" LIKE '0x40c10f19%' OR "input" LIKE '0x42966c68%')
    AND "block_timestamp" >= 1672531200000000 -- Unix timestamp for '2023-01-01 00:00:00' in microseconds
    AND "block_timestamp" < 1704067200000000  -- Unix timestamp for '2024-01-01 00:00:00' in microseconds
),
daily_value_change AS (
  SELECT 
    DATE_TRUNC('DAY', TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) AS transaction_date,
    SUM(
      CASE 
        WHEN operation = 'mint' THEN amount_in_millions
        WHEN operation = 'burn' THEN -amount_in_millions
      END
    ) AS daily_change
  FROM parsed_transactions
  GROUP BY DATE_TRUNC('DAY', TO_TIMESTAMP_NTZ("block_timestamp" / 1000000))
)
SELECT 
  transaction_date,
  '$' || TO_VARCHAR(ROUND(daily_change, 2), '999,999,999,999.00') AS "Δ Total Market Value (USD)"
FROM daily_value_change
ORDER BY transaction_date DESC NULLS LAST;