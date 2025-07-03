WITH monthly_totals AS (
    SELECT 
        "block_timestamp_month",
        COUNT(*) AS "transaction_count",
        SUM("output_value") AS "total_volume",
        SUM("input_count") AS "total_inputs",
        SUM("output_count") AS "total_outputs"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE "block_timestamp_month" BETWEEN '2021-01-01' AND '2021-12-31'
    GROUP BY "block_timestamp_month"
),
coinjoin_metrics AS (
    SELECT 
        "block_timestamp_month",
        COUNT(*) AS "coinjoin_count",
        SUM("output_value") AS "coinjoin_volume",
        SUM("input_count") AS "total_inputs",
        SUM("output_count") AS "total_outputs"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE "block_timestamp_month" BETWEEN '2021-01-01' AND '2021-12-31'
      AND "output_count" > 2 
      AND "output_value" <= "input_value"
    GROUP BY "block_timestamp_month"
),
combined_metrics AS (
    SELECT 
        monthly."block_timestamp_month",
        (coinjoin."coinjoin_count"::FLOAT / monthly."transaction_count") * 100 AS "coinjoin_transaction_percentage",
        (coinjoin."coinjoin_volume"::FLOAT / monthly."total_volume") * 100 AS "coinjoin_volume_percentage",
        ((coinjoin."total_inputs" + coinjoin."total_outputs")::FLOAT / (monthly."total_inputs" + monthly."total_outputs")) * 50 AS "utxo_ratio_percentage"
    FROM monthly_totals monthly
    JOIN coinjoin_metrics coinjoin
    ON monthly."block_timestamp_month" = coinjoin."block_timestamp_month"
)
SELECT 
    EXTRACT(MONTH FROM "block_timestamp_month") AS "month",
    ROUND("coinjoin_transaction_percentage", 1) AS "coinjoin_transaction_percentage",
    ROUND("utxo_ratio_percentage", 1) AS "utxo_ratio_percentage",
    ROUND("coinjoin_volume_percentage", 1) AS "coinjoin_volume_percentage"
FROM combined_metrics
ORDER BY "coinjoin_volume_percentage" DESC NULLS LAST
LIMIT 1;