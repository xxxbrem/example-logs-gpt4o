WITH 
-- Step 1: Calculate yearly average output values from the combined INPUTS and OUTPUTS tables
merged_output_averages AS (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP(o."block_timestamp" / 1000000)) AS "year",
        AVG(o."value"::FLOAT) AS "average_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.OUTPUTS o
    GROUP BY 1
),
-- Step 2: Calculate yearly average output values directly from the TRANSACTIONS table
transaction_output_averages AS (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP(t."block_timestamp" / 1000000)) AS "year",
        AVG(t."output_value"::FLOAT) AS "average_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
    GROUP BY 1
),
-- Step 3: Join the two datasets on the common "year"
yearly_differences AS (
    SELECT 
        mo."year",
        mo."average_output_value" AS "merged_average",
        ta."average_output_value" AS "transaction_average",
        mo."average_output_value" - ta."average_output_value" AS "difference"
    FROM merged_output_averages mo
    INNER JOIN transaction_output_averages ta ON mo."year" = ta."year"
)
-- Step 4: Return the yearly differences for years with data in both methods
SELECT 
    "year",
    "merged_average",
    "transaction_average",
    "difference"
FROM yearly_differences
ORDER BY "year";