WITH CoinJoinTransactions AS (
    -- Step 1: Identify transactions with >2 outputs, output_value <= input_value, and multiple equal-value outputs
    SELECT DISTINCT t."block_timestamp_month", t."hash", 
        AVG(t."input_count") AS "avg_input_utxos", 
        AVG(t."output_count") AS "avg_output_utxos"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
    JOIN (
        SELECT "hash"
        FROM (
            SELECT "hash", "output_value", COUNT(*) AS "output_value_count"
            FROM (
                SELECT t."hash", f.value::VARIANT:"value"::NUMBER AS "output_value"
                FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t, 
                     LATERAL FLATTEN(input => t."outputs") f
                WHERE t."block_timestamp_month" LIKE '2021-%'
                  AND t."output_count" > 2
                  AND t."output_value" <= t."input_value"
            )
            GROUP BY "hash", "output_value"
        )
        WHERE "output_value_count" > 1
    ) cj
    ON t."hash" = cj."hash"
    GROUP BY t."block_timestamp_month", t."hash"
),
MonthlyStats AS (
    -- Step 2: Calculate CoinJoin stats and total transaction stats by month
    SELECT 
        t."block_timestamp_month", 
        COUNT(DISTINCT cj."hash") AS "coinjoin_count",
        AVG(cj."avg_input_utxos") AS "avg_input_utxos",
        AVG(cj."avg_output_utxos") AS "avg_output_utxos",
        SUM(t."output_value") AS "coinjoin_volume",
        tr."transaction_count",
        vol."total_transaction_volume"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t
    LEFT JOIN CoinJoinTransactions cj 
    ON t."hash" = cj."hash"
    JOIN (
        SELECT "block_timestamp_month", COUNT(*) AS "transaction_count"
        FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
        WHERE "block_timestamp_month" LIKE '2021-%'
        GROUP BY "block_timestamp_month"
    ) tr
    ON t."block_timestamp_month" = tr."block_timestamp_month"
    JOIN (
        SELECT "block_timestamp_month", SUM("output_value") AS "total_transaction_volume"
        FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
        WHERE "block_timestamp_month" LIKE '2021-%'
        GROUP BY "block_timestamp_month"
    ) vol
    ON t."block_timestamp_month" = vol."block_timestamp_month"
    GROUP BY t."block_timestamp_month", tr."transaction_count", vol."total_transaction_volume"
),
HighestCoinJoinMonth AS (
    -- Step 3: Compute metrics and sort by CoinJoin transaction volume percentage descending
    SELECT 
        "block_timestamp_month", 
        ROUND(("coinjoin_count"::FLOAT / "transaction_count") * 100, 1) AS "coinjoin_tx_percentage",
        ROUND(("coinjoin_volume"::FLOAT / "total_transaction_volume") * 100, 1) AS "coinjoin_volume_percentage",
        ROUND((("avg_input_utxos" + "avg_output_utxos") / 2), 1) AS "avg_utxo_involvement"
    FROM MonthlyStats
    ORDER BY "coinjoin_volume_percentage" DESC
    LIMIT 1
)
SELECT 
    "block_timestamp_month", 
    EXTRACT(MONTH FROM "block_timestamp_month") AS "month", 
    "coinjoin_tx_percentage", 
    "avg_utxo_involvement", 
    "coinjoin_volume_percentage"
FROM HighestCoinJoinMonth;