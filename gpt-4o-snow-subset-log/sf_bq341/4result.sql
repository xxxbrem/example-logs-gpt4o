SELECT 
  "address", 
  "balance"
FROM (
  SELECT 
    "address", 
    SUM("value_numeric") AS "balance"
  FROM (
    SELECT 
      "from_address" AS "address", 
      TRY_CAST("value" AS NUMERIC) * -1 AS "value_numeric"
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS 
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'

    UNION ALL
    
    SELECT 
      "to_address" AS "address", 
      TRY_CAST("value" AS NUMERIC) AS "value_numeric"
    FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS 
    WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
  ) AS combined_transactions
  GROUP BY "address"
) 
WHERE "balance" > 0
ORDER BY "balance" ASC
LIMIT 3;