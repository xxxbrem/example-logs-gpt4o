WITH merged_outputs AS (
    SELECT DATE_PART('YEAR', TO_TIMESTAMP(o."block_timestamp" / 1000000)) AS "year",
           AVG(o."value"::NUMERIC) AS "average_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.OUTPUTS o
    LEFT JOIN CRYPTO.CRYPTO_BITCOIN.INPUTS i
    ON o."transaction_hash" = i."spent_transaction_hash" AND o."index" = i."spent_output_index"
    WHERE i."spent_transaction_hash" IS NULL -- Filter to include only unspent outputs
    GROUP BY DATE_PART('YEAR', TO_TIMESTAMP(o."block_timestamp" / 1000000))
),
transaction_outputs AS (
    SELECT DATE_PART('YEAR', TO_TIMESTAMP("block_timestamp" / 1000000)) AS "year",
           AVG("output_value"::NUMERIC) AS "average_output_value"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    GROUP BY DATE_PART('YEAR', TO_TIMESTAMP("block_timestamp" / 1000000))
)
SELECT mo."year", 
       mo."average_output_value" - tr."average_output_value" AS "difference_in_average"
FROM merged_outputs mo
INNER JOIN transaction_outputs tr
ON mo."year" = tr."year"
ORDER BY mo."year";