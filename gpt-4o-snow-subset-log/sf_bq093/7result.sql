WITH transactions_filtered AS (
    -- Filter transactions for October 14, 2016, with successful receipt status
    SELECT 
        "from_address", 
        "to_address", 
        "value", 
        "receipt_gas_used", 
        "gas_price", 
        "block_number", 
        "hash" AS "transaction_hash"
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE 
        DATE_TRUNC('DAY', TO_TIMESTAMP("block_timestamp" / 1e6)) = '2016-10-14'
        AND "receipt_status" = 1
),
traces_filtered AS (
    -- Exclude internal traces and filter for October 14, 2016
    SELECT 
        "from_address", 
        "to_address", 
        "value", 
        "block_number", 
        "transaction_hash"
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRACES
    WHERE 
        DATE_TRUNC('DAY', TO_TIMESTAMP("block_timestamp" / 1e6)) = '2016-10-14'
        AND "trace_type" NOT IN ('delegatecall', 'callcode', 'staticcall')
),
gas_calculations AS (
    -- Calculate gas fees paid by senders and gas earnings by miners
    SELECT 
        "from_address" AS "address", 
        -SUM("receipt_gas_used" * "gas_price") AS "net_balance_change"
    FROM transactions_filtered
    WHERE "receipt_gas_used" IS NOT NULL AND "gas_price" IS NOT NULL
    GROUP BY "from_address"

    UNION ALL

    SELECT 
        b."miner" AS "address", 
        SUM("gas_used" * tf."gas_price") AS "net_balance_change"
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.BLOCKS b
    INNER JOIN transactions_filtered tf
        ON b."number" = tf."block_number"
    WHERE DATE_TRUNC('DAY', TO_TIMESTAMP(b."timestamp" / 1e6)) = '2016-10-14'
    AND b."gas_used" IS NOT NULL AND tf."gas_price" IS NOT NULL
    GROUP BY b."miner"
),
net_balance_changes AS (
    -- Aggregate all debits, credits, and gas-related changes in balance
    SELECT 
        "to_address" AS "address", 
        SUM("value") AS "net_balance_change"
    FROM transactions_filtered
    GROUP BY "to_address"

    UNION ALL

    SELECT 
        "from_address" AS "address", 
        -SUM("value") AS "net_balance_change"
    FROM transactions_filtered
    GROUP BY "from_address"

    UNION ALL

    SELECT 
        "to_address" AS "address", 
        SUM("value") AS "net_balance_change"
    FROM traces_filtered
    GROUP BY "to_address"

    UNION ALL

    SELECT 
        "from_address" AS "address", 
        -SUM("value") AS "net_balance_change"
    FROM traces_filtered
    GROUP BY "from_address"

    UNION ALL

    SELECT 
        "address", 
        "net_balance_change"
    FROM gas_calculations
),
final_aggregated_changes AS (
    -- Aggregate net balance changes per address
    SELECT 
        "address",
        SUM("net_balance_change") AS "total_net_balance_change"
    FROM net_balance_changes
    GROUP BY "address"
)
-- Retrieve the maximum and minimum net balance changes
SELECT 
    MAX("total_net_balance_change") AS "maximum_net_balance_change",
    MIN("total_net_balance_change") AS "minimum_net_balance_change"
FROM final_aggregated_changes;