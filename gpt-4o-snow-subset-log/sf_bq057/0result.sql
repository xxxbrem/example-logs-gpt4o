WITH CoinJoinTransactions AS (
    SELECT 
        t."block_timestamp_month",
        t."hash" AS "transaction_hash",
        t."input_count",
        t."output_count",
        t."input_value",
        t."output_value",
        CASE 
            WHEN t."output_count" > 2 
                 AND t."output_value" <= t."input_value"
                 AND ARRAY_SIZE(ARRAY_AGG(CAST(JSON_EXTRACT_PATH_TEXT(o.value, 'value') AS FLOAT))) = 1 THEN 1
            ELSE 0
        END AS "is_coinjoin"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t,
    LATERAL FLATTEN(input => t."outputs") o
    WHERE t."block_timestamp" >= 1609459200000000 -- 2021-01-01
      AND t."block_timestamp" < 1640995200000000 -- 2022-01-01
    GROUP BY 
        t."block_timestamp_month",
        t."hash",
        t."input_count",
        t."output_count",
        t."input_value",
        t."output_value"
),
CoinJoinStats AS (
    SELECT 
        "block_timestamp_month",
        COUNT(*) AS "total_transactions",
        SUM("is_coinjoin") AS "coinjoin_transactions",
        ROUND(SUM("is_coinjoin") * 100.0 / COUNT(*), 1) AS "coinjoin_percentage",
        ROUND(SUM(CASE WHEN "is_coinjoin" = 1 THEN "input_count" ELSE 0 END) * 100.0 
              / SUM("input_count"), 1) AS "input_utxo_percentage",
        ROUND(SUM(CASE WHEN "is_coinjoin" = 1 THEN "output_count" ELSE 0 END) * 100.0 
              / SUM("output_count"), 1) AS "output_utxo_percentage",
        ROUND(SUM(CASE WHEN "is_coinjoin" = 1 THEN "output_value" ELSE 0 END) * 100.0 
              / SUM("output_value"), 1) AS "coinjoin_volume_percentage"
    FROM CoinJoinTransactions
    GROUP BY "block_timestamp_month"
    ORDER BY "coinjoin_volume_percentage" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    EXTRACT(MONTH FROM "block_timestamp_month") AS "month",
    "coinjoin_percentage",
    ROUND((("input_utxo_percentage" + "output_utxo_percentage") / 2), 1) AS "avg_utxo_percentage",
    "coinjoin_volume_percentage"
FROM CoinJoinStats;