WITH MINT_BURN_TRANSACTIONS AS (
    SELECT 
        "block_timestamp",
        TO_DATE(DATEADD(SECOND, CAST("block_timestamp" AS BIGINT) / 1000000, '1970-01-01')) AS "transaction_date",
        CAST(CONCAT('0x', LTRIM(SUBSTR("input", 75, 64), '0')) AS FLOAT) / 1000000 AS "amount_millions",
        'Mint' AS "operation"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE 
        "input" LIKE '0x40c10f19%' 
        AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'

    UNION ALL

    SELECT 
        "block_timestamp",
        TO_DATE(DATEADD(SECOND, CAST("block_timestamp" AS BIGINT) / 1000000, '1970-01-01')) AS "transaction_date",
        -CAST(CONCAT('0x', LTRIM(SUBSTR("input", 11, 64), '0')) AS FLOAT) / 1000000 AS "amount_millions",
        'Burn' AS "operation"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE 
        "input" LIKE '0x42966c68%' 
        AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
)
  
SELECT 
    "transaction_date",
    TO_CHAR(SUM("amount_millions"), 'FM$999,999,999,990.00') AS "Δ Total Market Value"
FROM 
    MINT_BURN_TRANSACTIONS
WHERE 
    "transaction_date" BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    "transaction_date"
ORDER BY 
    "transaction_date" DESC NULLS LAST;