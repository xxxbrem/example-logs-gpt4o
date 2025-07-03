WITH usdc_transactions AS (
    SELECT 
        "hash",
        "input",
        "block_timestamp",
        "from_address",
        "to_address",
        CASE 
            WHEN "input" ILIKE '0x40c10f19%' THEN 1  -- Minting operation
            WHEN "input" ILIKE '0x42966c68%' THEN -1 -- Burning operation
        END AS operation_type,
        CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 
            CASE 
                WHEN "input" ILIKE '0x40c10f19%' THEN 75 -- Extract minting amount
                WHEN "input" ILIKE '0x42966c68%' THEN 11 -- Extract burning amount
            END, 64), '0')) AS FLOAT) / 1000000 AS amount_in_millions -- Convert from smallest unit to millions
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
    WHERE 
        "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
        AND ("input" ILIKE '0x40c10f19%' OR "input" ILIKE '0x42966c68%')
        AND "block_timestamp" >= 1672531200000000 -- Start of 2023 (timestamp in microseconds)
        AND "block_timestamp" < 1704067200000000  -- Start of 2024 (timestamp in microseconds)
),
daily_market_value_change AS (
    SELECT 
        DATE_TRUNC('DAY', TO_TIMESTAMP("block_timestamp" / 1000000)) AS transaction_date,
        SUM(operation_type * amount_in_millions) AS daily_change_in_millions
    FROM 
        usdc_transactions
    GROUP BY 
        1
)
SELECT 
    transaction_date,
    CONCAT('$', TO_CHAR(daily_change_in_millions, 'FM999,999,999.00')) AS "Δ Total Market Value"
FROM 
    daily_market_value_change
ORDER BY 
    transaction_date DESC NULLS LAST;