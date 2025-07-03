WITH balance_calculation AS (
    SELECT 
        "to_address" AS "address",
        SUM(TRY_CAST("value" AS NUMERIC)) AS "balance"
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    GROUP BY "to_address"
    HAVING SUM(TRY_CAST("value" AS NUMERIC)) > 0
),
sorted_balances AS (
    SELECT 
        "address", 
        "balance"
    FROM balance_calculation
    ORDER BY "balance" ASC
)
SELECT 
    "address", 
    "balance"
FROM sorted_balances
LIMIT 3;