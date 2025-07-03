WITH token_transfers AS (
    SELECT 
        t."to_address" AS address,
        TRY_TO_NUMERIC(t."value") AS received_value,
        0 AS sent_value
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS t
    WHERE t."token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    
    UNION ALL
    
    SELECT 
        t."from_address" AS address,
        0 AS received_value,
        TRY_TO_NUMERIC(t."value") AS sent_value
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS t
    WHERE t."token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
),
address_balances AS (
    SELECT 
        address,
        SUM(received_value) - SUM(sent_value) AS balance
    FROM token_transfers
    GROUP BY address
    HAVING SUM(received_value) - SUM(sent_value) > 0
)
SELECT 
    address,
    balance
FROM address_balances
ORDER BY balance ASC
LIMIT 3;