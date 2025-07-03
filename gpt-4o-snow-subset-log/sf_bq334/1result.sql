WITH 
-- Step 1: Calculate yearly averages for output values from merged INPUTS and OUTPUTS tables
MergedOutputAverages AS (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ(o."block_timestamp" / 1000000)) AS "year",
        AVG(o."value"::DOUBLE) AS "average_merged_output_value"
    FROM 
        CRYPTO.CRYPTO_BITCOIN.OUTPUTS o
    JOIN 
        CRYPTO.CRYPTO_BITCOIN.INPUTS i
    ON 
        o."transaction_hash" = i."spent_transaction_hash" 
        AND o."index" = i."spent_output_index" -- Match output records that have been spent
    GROUP BY 
        EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ(o."block_timestamp" / 1000000))
),

-- Step 2: Calculate yearly averages for output values from the TRANSACTIONS table directly
TransactionOutputAverages AS (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ(t."block_timestamp" / 1000000)) AS "year",
        AVG(t."output_value"::DOUBLE) AS "average_transaction_output_value"
    FROM 
        CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
    GROUP BY 
        EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ(t."block_timestamp" / 1000000))
)

-- Step 3: Compare the yearly averages from both methods and calculate the difference
SELECT 
    m."year",
    m."average_merged_output_value",
    t."average_transaction_output_value",
    (m."average_merged_output_value" - t."average_transaction_output_value") AS "difference"
FROM 
    MergedOutputAverages m
JOIN 
    TransactionOutputAverages t
ON 
    m."year" = t."year"
ORDER BY 
    m."year" ASC;