SELECT 
    "address", 
    "net_balance"
FROM 
    (
        SELECT 
            COALESCE(inflows."address", outflows."address") AS "address", 
            COALESCE(inflows."total_inflow", 0) - COALESCE(outflows."total_outflow", 0) AS "net_balance"
        FROM 
            (SELECT 
                 "to_address" AS "address", 
                 SUM(CAST("value" AS NUMERIC)) AS "total_inflow"
             FROM 
                 CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
             WHERE 
                 "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
             GROUP BY 
                 "to_address") inflows
        FULL OUTER JOIN
            (SELECT 
                 "from_address" AS "address", 
                 SUM(CAST("value" AS NUMERIC)) AS "total_outflow"
             FROM 
                 CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS
             WHERE 
                 "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
             GROUP BY 
                 "from_address") outflows
        ON 
            inflows."address" = outflows."address"
    ) balances
WHERE 
    "net_balance" > 0
ORDER BY 
    "net_balance" ASC
LIMIT 3;