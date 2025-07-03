WITH MintBurnTransactions AS (
    -- Extract market value (in millions) for mint transactions
    SELECT 
        DATE_FROM_PARTS(
            YEAR(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)),
            MONTH(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)),
            DAY(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000))
        ) AS "transaction_date", 
        CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 75, 64), '0')) AS FLOAT) / 1000000 AS "value_in_millions",
        1 AS "change_direction"
    FROM CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE "input" LIKE '0x40c10f19%'
      AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
    
    UNION ALL
    
    -- Extract market value (in millions) for burn transactions
    SELECT 
        DATE_FROM_PARTS(
            YEAR(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)),
            MONTH(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)),
            DAY(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000))
        ) AS "transaction_date", 
        -1 * CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 11, 64), '0')) AS FLOAT) / 1000000 AS "value_in_millions",
        -1 AS "change_direction"
    FROM CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE "input" LIKE '0x42966c68%'
      AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
),
DailyMarketValueChange AS (
    -- Calculate daily change in market value
    SELECT 
        "transaction_date",
        SUM("value_in_millions") AS "daily_change"
    FROM MintBurnTransactions
    GROUP BY "transaction_date"
)
SELECT 
    "transaction_date",
    TO_CHAR(SUM("daily_change"), 'FM$999999999999.00') AS "Δ Total Market Value"
FROM DailyMarketValueChange
WHERE "transaction_date" BETWEEN DATE_FROM_PARTS(2023, 1, 1) AND DATE_FROM_PARTS(2023, 12, 31)
GROUP BY "transaction_date"
ORDER BY "transaction_date" DESC NULLS LAST;