WITH total_received AS (
    SELECT "to_address" AS "address", SUM(TRY_CAST("value" AS FLOAT)) AS "received"
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    GROUP BY "to_address"
),
total_sent AS (
    SELECT "from_address" AS "address", SUM(TRY_CAST("value" AS FLOAT)) AS "sent"
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    GROUP BY "from_address"
),
net_balances AS (
    SELECT 
        r."address", 
        COALESCE("received", 0) - COALESCE("sent", 0) AS "net_balance"
    FROM total_received r
    FULL OUTER JOIN total_sent s ON r."address" = s."address"
    WHERE COALESCE("received", 0) - COALESCE("sent", 0) > 0
)
SELECT "address", "net_balance"
FROM net_balances
ORDER BY "net_balance" ASC
LIMIT 3;