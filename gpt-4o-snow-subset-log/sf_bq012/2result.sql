WITH net_balances AS (
    SELECT 
        COALESCE(incoming."address", outgoing."address") AS "address",
        SUM(COALESCE(incoming.total_incoming, 0) - COALESCE(outgoing.total_outgoing, 0)) AS net_balance
    FROM (
        SELECT 
            "to_address" AS "address",
            SUM("value") AS total_incoming
        FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
        WHERE "trace_type" = 'call'
          AND ("call_type" IS NULL OR "call_type" = 'call')
          AND "status" = 1
          AND "to_address" IS NOT NULL
        GROUP BY "to_address"
    ) AS incoming
    FULL OUTER JOIN (
        SELECT 
            "from_address" AS "address",
            SUM("value") AS total_outgoing
        FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
        WHERE "trace_type" = 'call'
          AND ("call_type" IS NULL OR "call_type" = 'call')
          AND "status" = 1
          AND "from_address" IS NOT NULL
        GROUP BY "from_address"
    ) AS outgoing
    ON incoming."address" = outgoing."address"
    GROUP BY COALESCE(incoming."address", outgoing."address")
),
miner_rewards AS (
    SELECT 
        "miner" AS "address",
        SUM(("gas_used" * "difficulty") / POW(10, 18)) AS miner_rewards
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."BLOCKS"
    WHERE "miner" IS NOT NULL
    GROUP BY "miner"
),
gas_fees AS (
    SELECT 
        "from_address" AS "address",
        SUM("receipt_gas_used" * "gas_price") AS total_gas_fee
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRANSACTIONS"
    WHERE "from_address" IS NOT NULL
      AND "receipt_gas_used" IS NOT NULL
      AND "gas_price" IS NOT NULL
    GROUP BY "from_address"
),
adjusted_balances AS (
    SELECT 
        net_balances."address",
        (net_balances.net_balance + COALESCE(miner_rewards.miner_rewards, 0)) AS overall_balance
    FROM net_balances
    LEFT JOIN miner_rewards
    ON net_balances."address" = miner_rewards."address"
),
final_balances AS (
    SELECT 
        adjusted_balances."address",
        (adjusted_balances.overall_balance - COALESCE(gas_fees.total_gas_fee, 0)) AS final_balance
    FROM adjusted_balances
    LEFT JOIN gas_fees
    ON adjusted_balances."address" = gas_fees."address"
)
SELECT 
    ROUND(AVG(final_balance) / POW(10, 15), 2) AS average_balance_in_quadrillions
FROM final_balances
WHERE final_balance IS NOT NULL
ORDER BY final_balance DESC NULLS LAST
LIMIT 10;