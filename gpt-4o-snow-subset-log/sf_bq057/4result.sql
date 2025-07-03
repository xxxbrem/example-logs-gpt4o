WITH monthly_stats AS (
    SELECT 
        DATE_PART('month', t."block_timestamp_month") AS "month",
        COUNT(t."hash") AS "total_transactions",
        SUM(CASE WHEN t."output_count" > 2 AND t."output_value" <= t."input_value" THEN 1 ELSE 0 END) AS "coinjoin_transactions",
        SUM(t."output_value") AS "total_volume",
        SUM(CASE WHEN t."output_count" > 2 AND t."output_value" <= t."input_value" THEN t."output_value" ELSE 0 END) AS "coinjoin_volume",
        SUM(CASE WHEN t."output_count" > 2 AND t."output_value" <= t."input_value" THEN input_agg."input_count" ELSE 0 END) AS "input_utxos_coinjoin",
        SUM(CASE WHEN t."output_count" > 2 AND t."output_value" <= t."input_value" THEN t."output_count" ELSE 0 END) AS "output_utxos_coinjoin"
    FROM 
        CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
    LEFT JOIN (
        SELECT 
            "spent_transaction_hash" AS "transaction_hash",
            COUNT(*) AS "input_count"
        FROM 
            CRYPTO.CRYPTO_BITCOIN.INPUTS
        GROUP BY 
            "spent_transaction_hash"
    ) input_agg
    ON 
        t."hash" = input_agg."transaction_hash"
    WHERE 
        DATE_PART('year', t."block_timestamp_month") = 2021
    GROUP BY 
        DATE_PART('month', t."block_timestamp_month")
)
SELECT 
    "month",
    ROUND(("coinjoin_transactions"::DECIMAL / NULLIF("total_transactions", 0)) * 100, 1) AS "coinjoin_txn_percent",
    ROUND((("input_utxos_coinjoin" + "output_utxos_coinjoin")::DECIMAL / 2) / NULLIF("total_transactions", 0) * 100, 1) AS "utxo_percent",
    ROUND(("coinjoin_volume"::DECIMAL / NULLIF("total_volume", 0)) * 100, 1) AS "coinjoin_volume_percent"
FROM 
    monthly_stats
ORDER BY 
    "coinjoin_volume_percent" DESC NULLS LAST
LIMIT 1;