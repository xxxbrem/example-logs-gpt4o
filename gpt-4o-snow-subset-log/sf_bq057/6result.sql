WITH CoinJoinTransactions AS (
    -- Filter only CoinJoin transactions in 2021
    SELECT t."hash",
           t."block_number",
           t."block_timestamp",
           t."input_value"::FLOAT AS "total_input_value",
           t."output_value"::FLOAT AS "total_output_value",
           COUNT(*) AS "output_count",
           ARRAY_AGG(f.value::VARIANT:"value"::FLOAT) AS "individual_output_values"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS t,
         LATERAL FLATTEN(input => t."outputs") f
    WHERE t."block_timestamp" BETWEEN 1609459201000000 AND 1640995199000000
          AND t."output_count" > 2  -- More than 2 outputs
          AND t."input_value" >= t."output_value" -- Total output value ≤ total input value
    GROUP BY t."hash", t."block_number", t."block_timestamp", t."input_value", t."output_value"
    HAVING COUNT(DISTINCT f.value::VARIANT:"value"::FLOAT) < COUNT(*) -- Multiple outputs of equal value
),
MonthlyCoinJoins AS (
    -- Calculate monthly CoinJoin-specific stats
    SELECT TO_CHAR(TO_TIMESTAMP(t."block_timestamp" / 1000000), 'MM') AS "month",
           COUNT(DISTINCT t."hash") AS "coinjoins_transaction_count",
           SUM(t."total_input_value") AS "coinjoins_volume"
    FROM CoinJoinTransactions t
    GROUP BY TO_CHAR(TO_TIMESTAMP(t."block_timestamp" / 1000000), 'MM')
),
MonthlyStats AS (
    -- Total transactions and volume monthly for normalization
    SELECT TO_CHAR(TO_TIMESTAMP("block_timestamp" / 1000000), 'MM') AS "month",
           COUNT(DISTINCT "hash") AS "total_transactions",
           SUM("input_value") AS "total_volume",
           SUM("input_count") AS "total_inputs",
           SUM("output_count") AS "total_outputs"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS
    WHERE "block_timestamp" BETWEEN 1609459201000000 AND 1640995199000000
    GROUP BY TO_CHAR(TO_TIMESTAMP("block_timestamp" / 1000000), 'MM')
),
JoinedStats AS (
    -- Combine CoinJoin-specific stats with total stats
    SELECT m."month",
           COALESCE(cj."coinjoins_transaction_count", 0) AS "coinjoins_transaction_count",
           m."total_transactions",
           COALESCE(cj."coinjoins_volume", 0) AS "coinjoins_volume",
           m."total_volume",
           m."total_inputs",
           m."total_outputs"
    FROM MonthlyStats m
    LEFT JOIN MonthlyCoinJoins cj
    ON m."month" = cj."month"
),
FinalStats AS (
    -- Calculate desired metrics
    SELECT "month",
           ROUND(("coinjoins_transaction_count" * 100.0) / "total_transactions", 1) AS "percentage_coinjoin_transactions",
           ROUND(("coinjoins_volume" * 100.0) / "total_volume", 1) AS "percentage_coinjoin_volume",
           ROUND(((COALESCE("coinjoins_transaction_count", 0) * 2.0) / ("total_inputs" + "total_outputs")) * 100.0, 1) AS "average_input_output_percentage"
    FROM JoinedStats
)
-- Return the month with the highest percentage of CoinJoin volume
SELECT "month",
       "percentage_coinjoin_transactions",
       "percentage_coinjoin_volume",
       "average_input_output_percentage"
FROM FinalStats
ORDER BY "percentage_coinjoin_volume" DESC
LIMIT 1;