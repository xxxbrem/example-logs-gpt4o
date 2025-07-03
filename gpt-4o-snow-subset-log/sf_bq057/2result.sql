WITH CoinJoinData AS (
    SELECT 
        EXTRACT(MONTH FROM "block_timestamp_month") AS "month",
        COUNT(*) AS "coinjoin_tx_count",
        SUM("output_value") AS "coinjoin_volume"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE 
        "output_count" > 2 AND 
        "output_value" <= "input_value" AND 
        "block_timestamp" >= 1609459200000000 AND 
        "block_timestamp" < 1640995200000000
    GROUP BY "month"
),
TotalData AS (
    SELECT 
        EXTRACT(MONTH FROM "block_timestamp_month") AS "month",
        COUNT(*) AS "total_tx_count",
        SUM("output_value") AS "total_tx_volume"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE 
        "block_timestamp" >= 1609459200000000 AND 
        "block_timestamp" < 1640995200000000
    GROUP BY "month"
),
UTXOStats AS (
    SELECT 
        EXTRACT(MONTH FROM t."block_timestamp_month") AS "month",
        COUNT(DISTINCT i.value::VARIANT:"addresses"::TEXT) AS "unique_input_addresses",
        COUNT(DISTINCT o.value::VARIANT:"addresses"::TEXT) AS "unique_output_addresses"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t,
    LATERAL FLATTEN(input => t."inputs") i,
    LATERAL FLATTEN(input => t."outputs") o
    WHERE 
        t."output_count" > 2 AND 
        t."output_value" <= t."input_value" AND 
        t."block_timestamp" >= 1609459200000000 AND 
        t."block_timestamp" < 1640995200000000
    GROUP BY "month"
),
CombinedData AS (
    SELECT 
        cj."month",
        cj."coinjoin_tx_count",
        td."total_tx_count",
        cj."coinjoin_volume",
        td."total_tx_volume",
        us."unique_input_addresses",
        us."unique_output_addresses",
        ROUND((cj."coinjoin_tx_count"::FLOAT / td."total_tx_count") * 100, 1) AS "coinjoin_transaction_percentage",
        ROUND((cj."coinjoin_volume"::FLOAT / td."total_tx_volume") * 100, 1) AS "coinjoin_volume_percentage",
        ROUND((us."unique_input_addresses"::FLOAT / td."total_tx_count") * 50 + 
              (us."unique_output_addresses"::FLOAT / td."total_tx_count") * 50, 1) AS "avg_utxo_percentage"
    FROM CoinJoinData cj
    JOIN TotalData td ON cj."month" = td."month"
    JOIN UTXOStats us ON cj."month" = us."month"
)
SELECT 
    "month",
    "coinjoin_transaction_percentage",
    "avg_utxo_percentage",
    "coinjoin_volume_percentage"
FROM CombinedData
ORDER BY "coinjoin_volume_percentage" DESC
LIMIT 1;