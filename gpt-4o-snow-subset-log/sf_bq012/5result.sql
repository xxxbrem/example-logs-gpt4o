WITH net_balances AS (
    SELECT 
        COALESCE("to_address", "from_address") AS "address", 
        SUM(CASE WHEN "to_address" IS NOT NULL THEN "value" ELSE 0 END) - 
        SUM(CASE WHEN "from_address" IS NOT NULL THEN "value" ELSE 0 END) AS "net_balance" 
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES 
    WHERE "trace_type" = 'call' 
      AND ("call_type" IS NULL OR "call_type" = 'call') 
      AND "status" = 1 
      AND "from_address" IS NOT NULL 
      AND "to_address" IS NOT NULL 
      AND "from_address" != '0x0000000000000000000000000000000000000000' 
      AND "to_address" != '0x0000000000000000000000000000000000000000'
    GROUP BY "address"
), miner_rewards AS (
    SELECT 
        "miner" AS "address", 
        SUM("gas_used" * "gas_limit" * 0.000000001) AS "reward"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS
    GROUP BY "miner"
), total_balances AS (
    SELECT 
        nb."address", 
        COALESCE(nb."net_balance", 0) + COALESCE(mr."reward", 0) AS "total_balance"
    FROM net_balances nb
    FULL OUTER JOIN miner_rewards mr
    ON nb."address" = mr."address"
), top_balances AS (
    SELECT 
        "address", 
        ("total_balance" / 1e15) AS "balance_in_quadrillions"
    FROM total_balances
    ORDER BY "balance_in_quadrillions" DESC NULLS LAST
    LIMIT 10
)
SELECT 
    ROUND(AVG("balance_in_quadrillions"), 2) AS "average_balance_in_quadrillions"
FROM top_balances;