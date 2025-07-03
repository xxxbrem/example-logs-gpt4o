WITH TokenTransfers AS (
    SELECT 
        "from_address", 
        "to_address", 
        TRY_CAST("value" AS NUMERIC) AS "value" 
    FROM 
        CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS 
    WHERE 
        "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
),
Balances AS (
    SELECT 
        "to_address" AS "address", 
        SUM("value") AS "balance" 
    FROM 
        TokenTransfers 
    WHERE 
        "value" > 0 
    GROUP BY 
        "to_address"
    UNION ALL
    SELECT 
        "from_address" AS "address", 
        -SUM("value") AS "balance" 
    FROM 
        TokenTransfers 
    WHERE 
        "value" > 0 
    GROUP BY 
        "from_address"
),
NetBalances AS (
    SELECT 
        "address", 
        SUM("balance") AS "net_balance" 
    FROM 
        Balances 
    GROUP BY 
        "address" 
    HAVING 
        SUM("balance") > 0
)
SELECT 
    "address", 
    "net_balance" 
FROM 
    NetBalances 
ORDER BY 
    "net_balance" ASC 
LIMIT 3;