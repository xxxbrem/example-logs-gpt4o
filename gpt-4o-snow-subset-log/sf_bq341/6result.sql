SELECT "address", 
       SUM("total_received") - COALESCE(SUM("total_sent"), 0) AS "net_balance"
FROM (
    SELECT "to_address" AS "address", 
           SUM(TRY_CAST("value" AS NUMERIC)) AS "total_received", 
           CAST(NULL AS NUMERIC) AS "total_sent"
    FROM "CRYPTO"."CRYPTO_ETHEREUM"."TOKEN_TRANSFERS"
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    GROUP BY "to_address"
    UNION ALL
    SELECT "from_address" AS "address", 
           CAST(NULL AS NUMERIC) AS "total_received", 
           SUM(TRY_CAST("value" AS NUMERIC)) AS "total_sent"
    FROM "CRYPTO"."CRYPTO_ETHEREUM"."TOKEN_TRANSFERS"
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    GROUP BY "from_address"
) AS combined_data
GROUP BY "address"
HAVING SUM("total_received") - COALESCE(SUM("total_sent"), 0) > 0
ORDER BY "net_balance" ASC
LIMIT 3;