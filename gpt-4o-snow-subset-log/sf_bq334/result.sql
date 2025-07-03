WITH 
-- Step 1: Calculate annual average output value from the OUTPUTS and INPUTS tables (merged method):
"MERGED_OUTPUTS_AVG" AS (
    SELECT 
        YEAR(TO_TIMESTAMP(o."block_timestamp" / 1000000)) AS "year", 
        AVG(CAST(o."value" AS DOUBLE)) AS "merged_avg_output_value" 
    FROM "CRYPTO"."CRYPTO_BITCOIN"."OUTPUTS" o 
    LEFT JOIN "CRYPTO"."CRYPTO_BITCOIN"."INPUTS" i 
    ON o."transaction_hash" = i."spent_transaction_hash" 
    AND o."index" = i."spent_output_index" 
    WHERE i."spent_transaction_hash" IS NULL 
    GROUP BY YEAR(TO_TIMESTAMP(o."block_timestamp" / 1000000))
),

-- Step 2: Calculate annual average output value directly from the TRANSACTIONS table:
"TRANSACTIONS_AVG" AS (
    SELECT 
        YEAR(TO_TIMESTAMP("block_timestamp" / 1000000)) AS "year", 
        AVG(CAST("output_value" AS DOUBLE)) AS "transactions_avg_output_value" 
    FROM "CRYPTO"."CRYPTO_BITCOIN"."TRANSACTIONS" 
    GROUP BY YEAR(TO_TIMESTAMP("block_timestamp" / 1000000))
),

-- Step 3: Join results from both methods for years common to both:
"YEARLY_DIFFERENCES" AS (
    SELECT 
        m."year", 
        m."merged_avg_output_value", 
        t."transactions_avg_output_value", 
        (m."merged_avg_output_value" - t."transactions_avg_output_value") AS "difference"
    FROM "MERGED_OUTPUTS_AVG" m 
    INNER JOIN "TRANSACTIONS_AVG" t 
    ON m."year" = t."year"
)

-- Step 4: Fetch the results:
SELECT 
    "year", 
    "merged_avg_output_value", 
    "transactions_avg_output_value", 
    "difference"
FROM "YEARLY_DIFFERENCES"
ORDER BY "year";