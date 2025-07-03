WITH bnb_token AS (
    -- Find the specific address of the 'BNB' token based on symbol
    SELECT "address"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TOKENS
    WHERE "symbol" ILIKE '%BNB%'
    LIMIT 1
), 
transfers_filtered AS (
    -- Exclude transactions involving zero address
    SELECT 
        "from_address", 
        "to_address",
        "value"::FLOAT / POWER(10, 18) AS "value", -- Convert value to standard units
        "token_address"
    FROM ETHEREUM_BLOCKCHAIN.ETHEREUM_BLOCKCHAIN.TOKEN_TRANSFERS
    WHERE "from_address" NOT ILIKE '%0x000%' 
      AND "to_address" NOT ILIKE '%0x000%'
),
bnb_transfers AS (
    -- Filter transactions only for the 'BNB' token
    SELECT *
    FROM transfers_filtered
    WHERE "token_address" = (SELECT "address" FROM bnb_token)
),
bnb_balances AS (
    -- Calculate total received and sent for each address
    SELECT 
        "to_address" AS "address",
        SUM("value") AS "received",
        0 AS "sent"
    FROM bnb_transfers
    GROUP BY "to_address"
    UNION ALL
    SELECT 
        "from_address" AS "address",
        0 AS "received",
        SUM("value") AS "sent"
    FROM bnb_transfers
    GROUP BY "from_address"
),
address_balances AS (
    -- Calculate net balance for each address
    SELECT 
        "address",
        SUM("received") - SUM("sent") AS "balance"
    FROM bnb_balances
    GROUP BY "address"
)
-- Calculate the total circulating supply
SELECT 
    SUM("balance") AS "total_circulating_supply"
FROM address_balances
WHERE "balance" > 0; -- Only include non-zero balances