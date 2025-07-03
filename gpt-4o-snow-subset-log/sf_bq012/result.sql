WITH 
-- Step 1: Calculate net incoming balances from TRACES
incoming_traces AS (
  SELECT 
    t."to_address" AS "address", 
    SUM(CAST(t."value" AS FLOAT)) AS "net_incoming"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES t
  WHERE t."status" = 1
    AND t."trace_type" = 'call'
    AND (t."call_type" IS NULL OR t."call_type" = 'call')
    AND t."to_address" IS NOT NULL
  GROUP BY t."to_address"
),
-- Step 2: Calculate net outgoing balances from TRACES
outgoing_traces AS (
  SELECT 
    t."from_address" AS "address", 
    SUM(CAST(t."value" AS FLOAT)) AS "net_outgoing"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES t
  WHERE t."status" = 1
    AND t."trace_type" = 'call'
    AND (t."call_type" IS NULL OR t."call_type" = 'call')
    AND t."from_address" IS NOT NULL
  GROUP BY t."from_address"
),
-- Step 3: Calculate net incoming ERC20/721 token transfers
incoming_token_transfers AS (
  SELECT 
    t."to_address" AS "address", 
    SUM(CAST(t."value" AS FLOAT)) AS "net_incoming"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TOKEN_TRANSFERS t
  WHERE t."to_address" IS NOT NULL
  GROUP BY t."to_address"
),
-- Step 4: Calculate net outgoing ERC20/721 token transfers
outgoing_token_transfers AS (
  SELECT 
    t."from_address" AS "address", 
    SUM(CAST(t."value" AS FLOAT)) AS "net_outgoing"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TOKEN_TRANSFERS t
  WHERE t."from_address" IS NOT NULL
  GROUP BY t."from_address"
),
-- Step 5: Calculate miner rewards from successful blocks
miner_rewards AS (
  SELECT 
    b."miner" AS "address", 
    SUM(CAST(b."gas_used" AS FLOAT)) AS "total_gas_used"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS b
  WHERE b."miner" IS NOT NULL
  GROUP BY b."miner"
),
-- Step 6: Calculate gas fees paid by senders from TRANSACTIONS
sender_gas_fees AS (
  SELECT 
    t."from_address" AS "address", 
    SUM(CAST(t."gas" AS FLOAT) * CAST(t."gas_price" AS FLOAT)) AS "total_gas_fees"
  FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRANSACTIONS t
  WHERE t."from_address" IS NOT NULL
    AND t."receipt_status" = 1
  GROUP BY t."from_address"
),
-- Step 7: Combine all balances
combined_balances AS (
  SELECT 
    COALESCE(t1."address", t2."address", t3."address", t4."address", m."address", g."address") AS "address",
    COALESCE(t1."net_incoming", 0) - COALESCE(t2."net_outgoing", 0) AS "trace_balance",
    COALESCE(t3."net_incoming", 0) - COALESCE(t4."net_outgoing", 0) AS "token_transfer_balance",
    COALESCE(m."total_gas_used", 0) AS "miner_balance",
    -COALESCE(g."total_gas_fees", 0) AS "gas_fee_balance"
  FROM incoming_traces t1
  FULL OUTER JOIN outgoing_traces t2 ON t1."address" = t2."address"
  FULL OUTER JOIN incoming_token_transfers t3 ON COALESCE(t1."address", t2."address") = t3."address"
  FULL OUTER JOIN outgoing_token_transfers t4 ON COALESCE(t1."address", t2."address", t3."address") = t4."address"
  FULL OUTER JOIN miner_rewards m ON COALESCE(t1."address", t2."address", t3."address", t4."address") = m."address"
  FULL OUTER JOIN sender_gas_fees g ON COALESCE(t1."address", t2."address", t3."address", t4."address", m."address") = g."address"
),
-- Step 8: Calculate net balances
net_balances AS (
  SELECT 
    "address", 
    (COALESCE("trace_balance", 0) + COALESCE("token_transfer_balance", 0) + COALESCE("miner_balance", 0) + COALESCE("gas_fee_balance", 0)) AS "net_balance"
  FROM combined_balances
  WHERE "address" IS NOT NULL
),
-- Step 9: Select top 10 addresses by net balance
top_10_balances AS (
  SELECT "address", "net_balance"
  FROM net_balances
  ORDER BY "net_balance" DESC NULLS LAST
  LIMIT 10
)
-- Step 10: Calculate average balance in quadrillions (10^15) and round to two decimal places
SELECT 
  ROUND(AVG("net_balance") / 1e15, 2) AS "average_balance_quadrillions"
FROM top_10_balances;