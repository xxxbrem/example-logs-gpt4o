SELECT "address", "net_balance"
FROM (
    SELECT
        accounts."address",
        COALESCE(received."total_received", 0) - COALESCE(sent."total_sent", 0) AS "net_balance"
    FROM (
        SELECT DISTINCT "from_address" AS "address" FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
        UNION ALL
        SELECT DISTINCT "to_address" AS "address" FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    ) AS accounts
    LEFT JOIN (
        SELECT "from_address", SUM(TRY_TO_NUMERIC("value")) AS "total_sent"
        FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
        GROUP BY "from_address"
    ) AS sent
    ON accounts."address" = sent."from_address"
    LEFT JOIN (
        SELECT "to_address", SUM(TRY_TO_NUMERIC("value")) AS "total_received"
        FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
        GROUP BY "to_address"
    ) AS received
    ON accounts."address" = received."to_address"
) AS balances
WHERE "net_balance" > 0
ORDER BY "net_balance" ASC
LIMIT 3;