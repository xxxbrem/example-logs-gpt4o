SELECT 
    "type", 
    MAX("balance") AS "max_balance", 
    MIN("balance") AS "min_balance"
FROM (
    SELECT 
        f.value::STRING AS "address", 
        t1."type", 
        SUM(CASE 
            WHEN t1."source" = 'INPUTS' THEN -t1."value" 
            ELSE t1."value" 
        END) AS "balance"
    FROM (
        -- Combine inputs and outputs data with a unified schema
        SELECT 
            "type", 
            "value", 
            "addresses", 
            'INPUTS' AS "source" 
        FROM CRYPTO.CRYPTO_BITCOIN_CASH.INPUTS 
        WHERE "block_timestamp" >= 1393632000000000 -- Start of March 2014
          AND "block_timestamp" < 1396310400000000 -- Start of April 2014
        
        UNION ALL
        
        SELECT 
            "type", 
            "value", 
            "addresses", 
            'OUTPUTS' AS "source" 
        FROM CRYPTO.CRYPTO_BITCOIN_CASH.OUTPUTS 
        WHERE "block_timestamp" >= 1393632000000000 -- Start of March 2014
          AND "block_timestamp" < 1396310400000000 -- Start of April 2014
    ) t1, LATERAL FLATTEN(input => t1."addresses") f -- Flatten the addresses column
    GROUP BY f.value::STRING, t1."type" -- Group balances by address and type
) t2
GROUP BY "type" -- Group maximum and minimum balances by address type
LIMIT 20;