WITH merged_averages AS (
  SELECT EXTRACT(YEAR FROM TO_TIMESTAMP(o."block_timestamp" / 1e6)) AS "year", 
         AVG(o."value"::NUMBER) AS "avg_output_value"
  FROM CRYPTO.CRYPTO_BITCOIN.INPUTS i
  JOIN CRYPTO.CRYPTO_BITCOIN.OUTPUTS o
    ON i."spent_transaction_hash" = o."transaction_hash" AND i."spent_output_index" = o."index"
  GROUP BY 1
),
transaction_averages AS (
  SELECT EXTRACT(YEAR FROM TO_TIMESTAMP(t."block_timestamp" / 1e6)) AS "year", 
         AVG(t."output_value"::NUMBER) AS "avg_output_value"
  FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
  GROUP BY 1
)
SELECT m."year", 
       m."avg_output_value" - t."avg_output_value" AS "difference"
FROM merged_averages m
JOIN transaction_averages t
  ON m."year" = t."year"
ORDER BY m."year"
LIMIT 20;