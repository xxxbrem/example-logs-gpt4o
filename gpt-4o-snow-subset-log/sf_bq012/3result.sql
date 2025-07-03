WITH VALID_TRACES AS (
    SELECT 
        "to_address" AS address,
        CAST("value" AS FLOAT) AS value_incoming,
        0 AS value_outgoing,
        ("gas" * COALESCE(NULLIF("gas_used", 0), "gas")) AS gas_fee_deduction,
        "block_number"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
    WHERE "trace_type" = 'call'
        AND ("call_type" IS NULL OR "call_type" = 'call')
        AND "status" = 1
        AND "to_address" IS NOT NULL
        AND "to_address" NOT ILIKE '%000000000000000000000000000000000000000%'
    UNION ALL
    SELECT 
        "from_address" AS address,
        0 AS value_incoming,
        CAST("value" AS FLOAT) AS value_outgoing,
        ("gas" * COALESCE(NULLIF("gas_used", 0), "gas")) AS gas_fee_deduction,
        "block_number"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
    WHERE "trace_type" = 'call'
        AND ("call_type" IS NULL OR "call_type" = 'call')
        AND "status" = 1
        AND "from_address" IS NOT NULL
        AND "from_address" NOT ILIKE '%000000000000000000000000000000000000000%'
),
MINER_REWARDS AS (
    SELECT 
        "miner" AS address,
        NULL AS value_incoming,
        0 AS value_outgoing,
        (SUM("gas_used" * "difficulty") * 1e-18) AS gas_fee_deduction,
        "number" AS block_number
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."BLOCKS"
    WHERE "miner" IS NOT NULL
    GROUP BY "miner", "difficulty", "number"
),
COMBINED_BALANCES AS (
    SELECT 
        address,
        SUM(value_incoming - value_outgoing - gas_fee_deduction) AS net_balance_in_wei
    FROM (
        SELECT * FROM VALID_TRACES
        UNION ALL
        SELECT * FROM MINER_REWARDS
    )
    GROUP BY address
),
TOP_10_ADDRESSES AS (
    SELECT 
        address,
        net_balance_in_wei
    FROM COMBINED_BALANCES
    WHERE net_balance_in_wei > 0
    ORDER BY net_balance_in_wei DESC NULLS LAST
    LIMIT 10
)
SELECT 
    ROUND(AVG(net_balance_in_wei) / 1e15, 2) AS average_balance_in_quadrillions
FROM TOP_10_ADDRESSES;