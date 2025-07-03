WITH net_balances AS (
    -- Calculate net incoming and outgoing values for addresses
    SELECT 
        COALESCE(incoming.address, outgoing.address) AS address,
        (COALESCE(incoming.total_incoming, 0) - COALESCE(outgoing.total_outgoing, 0)) AS net_balance
    FROM 
        -- Incoming transfers
        (SELECT "to_address" AS address, SUM("value") AS total_incoming
         FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
         WHERE "trace_type" = 'call'
         AND ("call_type" IS NULL OR "call_type" = 'call')
         AND "status" = 1
         GROUP BY "to_address") incoming
    FULL OUTER JOIN 
        -- Outgoing transfers
        (SELECT "from_address" AS address, SUM("value") AS total_outgoing
         FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
         WHERE "trace_type" = 'call'
         AND ("call_type" IS NULL OR "call_type" = 'call')
         AND "status" = 1
         GROUP BY "from_address") outgoing
    ON incoming.address = outgoing.address
),
miner_rewards AS (
    -- Calculate total gas rewards by miners from blocks
    SELECT 
        "miner" AS address,
        SUM("gas_used" * "difficulty") AS total_rewards
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS
    WHERE "miner" IS NOT NULL
    GROUP BY "miner"
),
gas_fees AS (
    -- Calculate total gas fees deducted from senders for successful transactions
    SELECT 
        "from_address" AS address,
        SUM("receipt_gas_used" * "gas_price") AS total_gas_fees
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRANSACTIONS
    WHERE "receipt_status" = 1
    AND "from_address" IS NOT NULL
    GROUP BY "from_address"
),
combined_balances AS (
    -- Combine net balances, miner rewards, and gas fees
    SELECT 
        COALESCE(balances.address, miner_rewards.address, gas_fees.address) AS address,
        (COALESCE(balances.net_balance, 0) + COALESCE(miner_rewards.total_rewards, 0) - COALESCE(gas_fees.total_gas_fees, 0)) AS combined_balance
    FROM net_balances balances
    FULL OUTER JOIN miner_rewards
    ON balances.address = miner_rewards.address
    FULL OUTER JOIN gas_fees
    ON COALESCE(balances.address, miner_rewards.address) = gas_fees.address
)
-- Calculate the average balance for the top 10 addresses
SELECT 
    ROUND(AVG(combined_balance / 1e15), 2) AS avg_balance_quadrillions
FROM combined_balances
WHERE combined_balance IS NOT NULL
ORDER BY combined_balance DESC NULLS LAST
LIMIT 10;