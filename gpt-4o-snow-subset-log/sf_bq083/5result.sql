WITH MintAndBurn AS (
    SELECT 
        "block_timestamp",
        DATEADD('SECOND', "block_timestamp" / 1000000, '1970-01-01')::DATE AS "transaction_date",
        CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 75, 64), '0')) AS DOUBLE) / 1000000 AS "value_in_millions",
        'Mint' AS "transaction_type"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE 
        "input" ILIKE '0x40c10f19%' 
        AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
    UNION ALL
    SELECT 
        "block_timestamp",
        DATEADD('SECOND', "block_timestamp" / 1000000, '1970-01-01')::DATE AS "transaction_date",
        -CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 11, 64), '0')) AS DOUBLE) / 1000000 AS "value_in_millions",
        'Burn' AS "transaction_type"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE 
        "input" ILIKE '0x42966c68%' 
        AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
)
SELECT 
    "transaction_date",
    TO_CHAR(SUM("value_in_millions"), 'FM$999,999,999,999,990.00') AS "Δ Total Market Value"
FROM 
    MintAndBurn
WHERE 
    "transaction_date" BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    "transaction_date"
ORDER BY 
    "transaction_date" DESC NULLS LAST;