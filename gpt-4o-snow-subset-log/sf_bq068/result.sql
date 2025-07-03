WITH DEBIT_ENTRIES AS (
    SELECT 
        FLATTENED_ADDRESSES.value::STRING AS "address",
        INP."type" AS "address_type",
        -INP."value" AS "balance" -- Treat inputs as debits (negative values)
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS INP, 
    LATERAL FLATTEN(input => INP."addresses") FLATTENED_ADDRESSES
    WHERE INP."block_timestamp" >= 1393632000000000 -- Start of March 2014
      AND INP."block_timestamp" < 1396310400000000 -- Start of April 2014
),
CREDIT_ENTRIES AS (
    SELECT 
        FLATTENED_ADDRESSES.value::STRING AS "address",
        OUT."type" AS "address_type",
        OUT."value" AS "balance" -- Treat outputs as credits (positive values)
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS OUT, 
    LATERAL FLATTEN(input => OUT."addresses") FLATTENED_ADDRESSES
    WHERE OUT."block_timestamp" >= 1393632000000000 -- Start of March 2014
      AND OUT."block_timestamp" < 1396310400000000 -- Start of April 2014
),
COMBINED_ENTRIES AS (
    SELECT * FROM DEBIT_ENTRIES
    UNION ALL
    SELECT * FROM CREDIT_ENTRIES
),
FINAL_BALANCES AS (
    SELECT 
        "address_type", 
        "address", 
        SUM("balance") AS "final_balance"
    FROM COMBINED_ENTRIES
    GROUP BY "address_type", "address"
)
SELECT 
    "address_type",
    MAX("final_balance") AS "max_balance",
    MIN("final_balance") AS "min_balance"
FROM FINAL_BALANCES
GROUP BY "address_type"
ORDER BY "address_type";