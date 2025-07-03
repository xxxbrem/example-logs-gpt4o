WITH MintBurnTransactions AS (
    SELECT 
        "hash", 
        DATEADD(SECOND, "block_timestamp" / 1000000, TIMESTAMP '1970-01-01 00:00:00') AS "transaction_date",
        "to_address",
        "input",
        CASE 
            WHEN "input" LIKE '0x40c10f19%' THEN 
                CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 75, 64), '0')) AS FLOAT) / 1000000
            WHEN "input" LIKE '0x42966c68%' THEN 
                -1 * CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 11, 64), '0')) AS FLOAT) / 1000000
            ELSE 0
        END AS "value_change_in_million"
    FROM CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
      AND ("input" LIKE '0x40c10f19%' OR "input" LIKE '0x42966c68%')
      AND YEAR(DATEADD(SECOND, "block_timestamp" / 1000000, TIMESTAMP '1970-01-01 00:00:00')) = 2023
),
DailyMarketValueChange AS (
    SELECT 
        DATE("transaction_date") AS "transaction_date",
        SUM("value_change_in_million") AS "total_change_in_million"
    FROM MintBurnTransactions
    GROUP BY DATE("transaction_date")
)
SELECT 
    "transaction_date",
    CONCAT('$', TO_CHAR("total_change_in_million", 'FM999999999.00')) AS "Δ_Total_Market_Value"
FROM DailyMarketValueChange
ORDER BY "transaction_date" DESC NULLS LAST;