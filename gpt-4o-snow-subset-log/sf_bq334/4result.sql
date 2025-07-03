WITH transactions_averages AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP("block_timestamp" / 1e6), 'YYYY') AS "year",
        AVG("output_value"::FLOAT) AS "avg_output_value"
    FROM "CRYPTO"."CRYPTO_BITCOIN"."TRANSACTIONS"
    GROUP BY 1
),
outputs_averages AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP(o."block_timestamp" / 1e6), 'YYYY') AS "year",
        AVG(o."value"::FLOAT) AS "avg_output_value"
    FROM "CRYPTO"."CRYPTO_BITCOIN"."OUTPUTS" o
    LEFT JOIN "CRYPTO"."CRYPTO_BITCOIN"."INPUTS" i
    ON o."transaction_hash" = i."spent_transaction_hash" AND o."index" = i."spent_output_index"
    WHERE i."spent_transaction_hash" IS NULL
    GROUP BY 1
),
common_years AS (
    SELECT DISTINCT t."year"
    FROM transactions_averages t
    INNER JOIN outputs_averages o
    ON t."year" = o."year"
)
SELECT 
    c."year",
    o."avg_output_value" AS "avg_output_merged",
    t."avg_output_value" AS "avg_output_transaction",
    o."avg_output_value" - t."avg_output_value" AS "avg_diff"
FROM common_years c
INNER JOIN outputs_averages o
ON c."year" = o."year"
INNER JOIN transactions_averages t
ON c."year" = t."year"
ORDER BY c."year"
LIMIT 20;