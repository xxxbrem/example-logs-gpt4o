WITH token_addresses AS (
    -- Identify the address of the BNB token
    SELECT "address"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKENS"
    WHERE "symbol" ILIKE '%BNB%'
),
transfers AS (
    -- Filter token transfers for the BNB token, excluding the zero address
    SELECT 
        "from_address", 
        "to_address", 
        CAST("value" AS FLOAT) / POWER(10, 18) AS "value"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS"
    WHERE "token_address" IN (SELECT "address" FROM token_addresses)
      AND "from_address" NOT ILIKE '0x000%'
      AND "to_address" NOT ILIKE '0x000%'
),
balances AS (
    -- Calculate the balance for each address (total received - total sent)
    SELECT 
        "to_address" AS "address", 
        SUM("value") AS "received"
    FROM transfers
    GROUP BY "to_address"

    UNION ALL

    SELECT 
        "from_address" AS "address",
        -SUM("value") AS "sent"
    FROM transfers
    GROUP BY "from_address"
),
aggregated_balances AS (
    -- Aggregate balances by each address
    SELECT 
        "address", 
        SUM("received") AS "balance"
    FROM balances
    GROUP BY "address"
)
-- Sum up balances of all addresses for the circulating supply
SELECT 
    SUM("balance") AS "total_circulating_supply"
FROM aggregated_balances
WHERE "balance" > 0;