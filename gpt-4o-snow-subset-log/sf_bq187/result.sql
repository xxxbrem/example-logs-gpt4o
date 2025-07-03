WITH TokenDetails AS (
    -- Filter the token address for 'BNB' based on the TOKENS table's symbol
    SELECT DISTINCT "address"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKENS"
    WHERE "symbol" ILIKE '%BNB%'
),
ReceivedAmounts AS (
    -- Calculate the total amount received by each address for the 'BNB' token
    SELECT 
        t."to_address" AS "address",
        SUM(CAST(t."value" AS FLOAT)) AS "total_received"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS" t
    JOIN TokenDetails td
    ON t."token_address" = td."address"
    WHERE t."to_address" NOT ILIKE '%0x000%' -- Exclude transactions involving the zero address
    GROUP BY t."to_address"
),
SentAmounts AS (
    -- Calculate the total amount sent by each address for the 'BNB' token
    SELECT 
        t."from_address" AS "address",
        SUM(CAST(t."value" AS FLOAT)) AS "total_sent"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS" t
    JOIN TokenDetails td
    ON t."token_address" = td."address"
    WHERE t."from_address" NOT ILIKE '%0x000%' -- Exclude transactions involving the zero address
    GROUP BY t."from_address"
)
-- Calculate the circulating supply by summing up balances (total_received - total_sent) for each address
SELECT 
    SUM((COALESCE(r."total_received", 0) - COALESCE(s."total_sent", 0))) / POW(10, 18) AS "circulating_supply"
FROM ReceivedAmounts r
LEFT JOIN SentAmounts s
ON r."address" = s."address";