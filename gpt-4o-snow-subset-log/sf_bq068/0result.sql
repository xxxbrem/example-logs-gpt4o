WITH FlattenedInputs AS (
    SELECT f.value::STRING AS "address",
           t."type" AS "address_type",
           SUM(CAST(t."value" AS FLOAT)) AS "total_debits"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS t,
         LATERAL FLATTEN(input => t."addresses") f
    WHERE t."block_timestamp" >= 1393632000000000
      AND t."block_timestamp" < 1396310400000000
    GROUP BY f.value::STRING, t."type"
),
FlattenedOutputs AS (
    SELECT f.value::STRING AS "address",
           t."type" AS "address_type",
           SUM(CAST(t."value" AS FLOAT)) AS "total_credits"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS t,
         LATERAL FLATTEN(input => t."addresses") f
    WHERE t."block_timestamp" >= 1393632000000000
      AND t."block_timestamp" < 1396310400000000
    GROUP BY f.value::STRING, t."type"
),
AddressBalances AS (
    SELECT COALESCE(o."address", i."address") AS "address",
           COALESCE(o."address_type", i."address_type") AS "address_type",
           COALESCE(o."total_credits", 0) - COALESCE(i."total_debits", 0) AS "final_balance"
    FROM FlattenedOutputs o
    FULL OUTER JOIN FlattenedInputs i
      ON o."address" = i."address" AND o."address_type" = i."address_type"
)
SELECT "address_type",
       MAX("final_balance") AS "max_balance",
       MIN("final_balance") AS "min_balance"
FROM AddressBalances
GROUP BY "address_type"
ORDER BY "address_type";