WITH merged_outputs_avg AS (
    -- Calculate yearly averages from merged input/output records
    SELECT DATE_PART('year', TO_TIMESTAMP("block_timestamp" / 1000000)) AS "year", 
           AVG("value"::NUMBER) AS "avg_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.OUTPUTS
    WHERE "type" IS NOT NULL -- Consider only valid output records
    GROUP BY 1
),
transactions_output_avg AS (
    -- Calculate yearly averages directly from the transactions table
    SELECT DATE_PART('year', TO_TIMESTAMP("block_timestamp" / 1000000)) AS "year", 
           AVG("output_value"::NUMBER) AS "avg_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    GROUP BY 1
)
-- Analyze differences in yearly averages between the two methods
SELECT m."year", 
       m."avg_output_value" - t."avg_output_value" AS "avg_difference"
FROM merged_outputs_avg m
JOIN transactions_output_avg t ON m."year" = t."year" -- Match years common to both methods
WHERE m."year" IS NOT NULL
ORDER BY m."year";