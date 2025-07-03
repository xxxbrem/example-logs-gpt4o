WITH transactions_on_date AS (
    SELECT 
        "from_address" AS address,
        -"value" AS balance_change,
        "receipt_gas_used" * "gas_price" AS gas_paid,
        NULL::NUMBER AS gas_earned
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE 
        "receipt_status" = 1
        AND "block_timestamp" >= 1476403200000000 -- October 14, 2016, 00:00:00 UTC
        AND "block_timestamp" < 1476489600000000 -- October 15, 2016, 00:00:00 UTC
    UNION ALL
    SELECT 
        "to_address" AS address,
        "value" AS balance_change,
        NULL::NUMBER AS gas_paid,
        NULL::NUMBER AS gas_earned
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE 
        "receipt_status" = 1
        AND "block_timestamp" >= 1476403200000000 -- October 14, 2016, 00:00:00 UTC
        AND "block_timestamp" < 1476489600000000 -- October 15, 2016, 00:00:00 UTC
    UNION ALL
    SELECT 
        "miner" AS address,
        NULL::NUMBER AS balance_change,
        NULL::NUMBER AS gas_paid,
        SUM("gas_used" * "difficulty") AS gas_earned
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.BLOCKS
    WHERE 
        "timestamp" >= 1476403200000000 -- October 14, 2016, 00:00:00 UTC
        AND "timestamp" < 1476489600000000 -- October 15, 2016, 00:00:00 UTC
    GROUP BY "miner"
)
SELECT 
    MAX(net_balance_change) AS max_net_balance_change,
    MIN(net_balance_change) AS min_net_balance_change
FROM (
    SELECT 
        address,
        SUM(COALESCE(balance_change, 0)) 
        + SUM(COALESCE(gas_earned, 0)) 
        - SUM(COALESCE(gas_paid, 0)) AS net_balance_change
    FROM transactions_on_date
    GROUP BY address
)