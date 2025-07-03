SELECT 
    ROUND(AVG(net_balances."net_balance" / 1e15), 2) AS "average_net_balance_quadrillions"
FROM 
    -- Subquery for selecting the top 10 addresses by net balance
    (SELECT DISTINCT 
         balances."address", 
         (COALESCE(balances."incoming_balance", 0) 
          - COALESCE(outgoing."outgoing_balance", 0) 
          - COALESCE(gas_fees."gas_fee_deductions", 0) 
          + COALESCE(miner_rewards."total_rewards", 0)) AS "net_balance"
     FROM 
         -- Subquery for incoming transfers (successful traces)
         (SELECT 
              "to_address" AS "address", 
              SUM("value") AS "incoming_balance"
          FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
          WHERE "status" = 1 
            AND "trace_type" = 'call' 
            AND ("call_type" IS NULL OR "call_type" = 'call')
            AND "to_address" IS NOT NULL
          GROUP BY "to_address") balances
     LEFT JOIN 
         -- Subquery for outgoing transfers
         (SELECT 
              "from_address" AS "address", 
              SUM("value") AS "outgoing_balance"
          FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
          WHERE "status" = 1 
            AND "trace_type" = 'call' 
            AND ("call_type" IS NULL OR "call_type" = 'call')
            AND "from_address" IS NOT NULL
          GROUP BY "from_address") outgoing
     ON balances."address" = outgoing."address"
     LEFT JOIN 
         -- Subquery for gas fee deductions
         (SELECT 
              "from_address", 
              SUM("receipt_gas_used" * "gas_price") AS "gas_fee_deductions"
          FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRANSACTIONS
          WHERE "receipt_gas_used" IS NOT NULL
            AND "from_address" IS NOT NULL
          GROUP BY "from_address") gas_fees
     ON balances."address" = gas_fees."from_address"
     LEFT JOIN 
         -- Subquery for miner rewards
         (SELECT 
              "miner", 
              SUM("gas_used" * "difficulty") AS "total_rewards"
          FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS
          WHERE "miner" IS NOT NULL
          GROUP BY "miner") miner_rewards
     ON balances."address" = miner_rewards."miner"
     WHERE balances."address" IS NOT NULL
     ORDER BY "net_balance" DESC NULLS LAST
     LIMIT 10) net_balances;