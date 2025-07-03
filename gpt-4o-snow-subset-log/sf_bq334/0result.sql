WITH 
-- Step 1: Calculate yearly average output values from merged INPUTS and OUTPUTS tables
merged_averages AS (
    SELECT 
        DATE_TRUNC('YEAR', TO_TIMESTAMP(o."block_timestamp" / 1e6)) AS "year", 
        AVG(CAST(o."value" AS DOUBLE)) AS "merged_avg_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.OUTPUTS o
    LEFT JOIN CRYPTO.CRYPTO_BITCOIN.INPUTS i
        ON o."transaction_hash" = i."spent_transaction_hash" 
        AND o."index" = i."spent_output_index"
    WHERE o."value" IS NOT NULL
    GROUP BY 1
),

-- Step 2: Calculate yearly average output values from the TRANSACTIONS table
transactions_averages AS (
    SELECT 
        DATE_TRUNC('YEAR', TO_TIMESTAMP("block_timestamp" / 1e6)) AS "year",
        AVG(CAST("output_value" AS DOUBLE)) AS "transactions_avg_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE "output_value" IS NOT NULL
    GROUP BY 1
),

-- Step 3: Combine the results and calculate the annual differences
annual_differences AS (
    SELECT 
        m."year",
        m."merged_avg_output_value",
        t."transactions_avg_output_value",
        m."merged_avg_output_value" - t."transactions_avg_output_value" AS "difference"
    FROM merged_averages m
    INNER JOIN transactions_averages t
        ON m."year" = t."year"
)

-- Step 4: Retrieve the final results
SELECT 
    "year", 
    "merged_avg_output_value", 
    "transactions_avg_output_value", 
    "difference"
FROM annual_differences
ORDER BY "year" ASC;