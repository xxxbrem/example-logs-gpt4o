WITH INPUT_SUM AS (
    SELECT 
        f.value::STRING AS "address", 
        i."type", 
        SUM(i."value") AS "total_debit"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS i, 
         LATERAL FLATTEN(input => i."addresses") f
    WHERE i."block_timestamp" BETWEEN 1393632000000000 AND 1396319999000000
    GROUP BY f.value::STRING, i."type"
),
OUTPUT_SUM AS (
    SELECT 
        f.value::STRING AS "address", 
        o."type", 
        SUM(o."value") AS "total_credit"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS o, 
         LATERAL FLATTEN(input => o."addresses") f
    WHERE o."block_timestamp" BETWEEN 1393632000000000 AND 1396319999000000
    GROUP BY f.value::STRING, o."type"
)
SELECT 
    o."type", 
    MAX(o."total_credit" - COALESCE(i."total_debit", 0)) AS "max_balance", 
    MIN(o."total_credit" - COALESCE(i."total_debit", 0)) AS "min_balance"
FROM OUTPUT_SUM o
LEFT JOIN INPUT_SUM i
ON o."address" = i."address" AND o."type" = i."type"
GROUP BY o."type";