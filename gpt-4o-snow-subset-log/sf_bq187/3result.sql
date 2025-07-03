-- Calculate the total circulating supply of 'BNB' tokens by summing balances of all non-zero addresses.
-- The balance for each address is calculated as total BNB received minus total BNB sent. 
-- The result is converted to units (by dividing the value by 10^18).

WITH bnb_token AS (
    -- Identify the address of the 'BNB' token
    SELECT "address" AS "bnb_address"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN."TOKENS"
    WHERE "symbol" = 'BNB'
    LIMIT 1
), 

token_transfers_filtered AS (
    -- Filter TOKEN_TRANSFERS for BNB token and exclude transactions involving the zero address
    SELECT 
        "from_address", 
        "to_address", 
        CAST("value" AS NUMERIC) / POWER(CAST(10 AS NUMERIC), 18) AS "value" 
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN."TOKEN_TRANSFERS"
    WHERE "token_address" = (SELECT "bnb_address" FROM bnb_token)
      AND "from_address" NOT LIKE '0x000%'
      AND "to_address" NOT LIKE '0x000%'
),

balances AS (
    -- Calculate balances for each address as total received minus total sent
    SELECT 
        "to_address" AS "address", 
        SUM("value") AS "received", 
        CAST(0 AS NUMERIC) AS "sent"
    FROM token_transfers_filtered
    GROUP BY "to_address"

    UNION ALL

    SELECT 
        "from_address" AS "address", 
        CAST(0 AS NUMERIC) AS "received", 
        SUM("value") AS "sent"
    FROM token_transfers_filtered
    GROUP BY "from_address"
),

address_balances AS (
    -- Aggregate the net balance (received - sent) for each address
    SELECT 
        "address", 
        SUM("received" - "sent") AS "balance"
    FROM balances
    GROUP BY "address"
)

-- Sum the balances of all addresses to get the total circulating supply
SELECT 
    SUM("balance") AS "total_circulating_supply"
FROM address_balances
WHERE "balance" > 0;