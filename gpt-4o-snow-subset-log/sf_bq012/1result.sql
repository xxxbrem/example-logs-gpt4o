WITH successful_traces AS (
    SELECT 
        "to_address" AS address,
        SUM("value") AS net_incoming
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
    WHERE ("call_type" IS NULL OR "call_type" = 'call')
      AND "trace_type" = 'call'
      AND "status" = 1
      AND "to_address" IS NOT NULL
    GROUP BY "to_address"
),
miner_rewards AS (
    SELECT 
        "miner" AS address,
        SUM("gas_used") AS reward_gas
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS
    WHERE "miner" IS NOT NULL
    GROUP BY "miner"
),
sender_gas_deductions AS (
    SELECT 
        "from_address" AS address,
        SUM("gas" * "gas_price") AS gas_expense
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRANSACTIONS
    WHERE "from_address" IS NOT NULL
      AND "receipt_status" = 1
    GROUP BY "from_address"
),
combined_balances AS (
    SELECT 
        address,
        COALESCE(SUM(net_incoming), 0) +
        COALESCE(SUM(reward_gas), 0) -
        COALESCE(SUM(gas_expense), 0) AS net_balance
    FROM (
        SELECT address, net_incoming, NULL AS reward_gas, NULL AS gas_expense FROM successful_traces
        UNION ALL
        SELECT address, NULL AS net_incoming, reward_gas, NULL AS gas_expense FROM miner_rewards
        UNION ALL
        SELECT address, NULL AS net_incoming, NULL AS reward_gas, gas_expense FROM sender_gas_deductions
    ) combined
    GROUP BY address
),
top_10_addresses AS (
    SELECT 
        address,
        net_balance
    FROM combined_balances
    WHERE address IS NOT NULL
    ORDER BY net_balance DESC NULLS LAST
    LIMIT 10
)
SELECT 
    ROUND(AVG(net_balance) / 1e15, 2) AS avg_balance_quadrillions
FROM top_10_addresses;