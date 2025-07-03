WITH
  -- Step 1: Calculate incoming balances from TRACES
  IncomingBalance AS (
    SELECT 
      "to_address" AS "address",
      SUM(CAST("value" AS NUMERIC)) AS "incoming_balance"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
    WHERE "status" = 1
      AND ("call_type" IS NULL OR "call_type" = 'call')
      AND "to_address" IS NOT NULL
    GROUP BY "to_address"
  ),
  
  -- Step 2: Calculate outgoing balances from TRACES
  OutgoingBalance AS (
    SELECT 
      "from_address" AS "address",
      SUM(CAST("value" AS NUMERIC)) AS "outgoing_balance"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRACES
    WHERE "status" = 1
      AND ("call_type" IS NULL OR "call_type" = 'call')
      AND "from_address" IS NOT NULL
    GROUP BY "from_address"
  ),

  -- Step 3: Calculate miner rewards from BLOCKS
  MinerRewards AS (
    SELECT 
      "miner" AS "address",
      SUM(("gas_used" * "difficulty") / POWER(10, 9)) AS "miner_reward" -- Difficulty-to-gas reward ratio in Wei
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.BLOCKS
    WHERE "miner" IS NOT NULL
    GROUP BY "miner"
  ),

  -- Step 4: Calculate sender gas fee deductions from TRANSACTIONS
  SenderGasFees AS (
    SELECT 
      "from_address" AS "address",
      SUM(CAST("gas_price" AS NUMERIC) * "receipt_gas_used") AS "gas_fee"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TRANSACTIONS
    WHERE "receipt_status" = 1
      AND "gas_price" IS NOT NULL
      AND "receipt_gas_used" IS NOT NULL
      AND "from_address" IS NOT NULL
    GROUP BY "from_address"
  ),

  -- Step 5: Compute net balances by aggregating all contributions
  NetBalances AS (
    SELECT 
      COALESCE(ib."address", ob."address", mr."address", sgf."address") AS "address",
      COALESCE(ib."incoming_balance", 0) - COALESCE(ob."outgoing_balance", 0) + COALESCE(mr."miner_reward", 0) - COALESCE(sgf."gas_fee", 0) AS "net_balance"
    FROM IncomingBalance ib
    FULL OUTER JOIN OutgoingBalance ob ON ib."address" = ob."address"
    FULL OUTER JOIN MinerRewards mr ON COALESCE(ib."address", ob."address") = mr."address"
    FULL OUTER JOIN SenderGasFees sgf ON COALESCE(ib."address", ob."address", mr."address") = sgf."address"
  ),

  -- Step 6: Select the top 10 addresses by net balance
  Top10Addresses AS (
    SELECT 
      "address",
      "net_balance"
    FROM NetBalances
    WHERE "net_balance" > 0 -- Exclude negative or zero balances
    ORDER BY "net_balance" DESC NULLS LAST
    LIMIT 10
  )

-- Step 7: Calculate the average balance of the top 10 addresses
SELECT 
  ROUND(AVG("net_balance") / POWER(10, 15), 2) AS "average_balance_quadrillion"
FROM Top10Addresses;