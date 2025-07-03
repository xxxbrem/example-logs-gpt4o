WITH OUTPUTS_SUMMARY AS (
    SELECT 
        "type" AS "address_type", 
        REGEXP_REPLACE("addresses", '\\[|\\]|\\n|\\s', '') AS "address", 
        SUM(CAST("value" AS FLOAT)) AS "total_output_value"
    FROM 
        "CRYPTO"."CRYPTO_BITCOIN_CASH"."OUTPUTS" 
    WHERE 
        "block_timestamp" >= 1393632000000000 
        AND "block_timestamp" < 1396310400000000
    GROUP BY 
        "type", "addresses"
), 
INPUTS_SUMMARY AS (
    SELECT 
        "type" AS "address_type", 
        REGEXP_REPLACE("addresses", '\\[|\\]|\\n|\\s', '') AS "address", 
        SUM(CAST("value" AS FLOAT)) AS "total_input_value"
    FROM 
        "CRYPTO"."CRYPTO_BITCOIN_CASH"."INPUTS" 
    WHERE 
        "block_timestamp" >= 1393632000000000 
        AND "block_timestamp" < 1396310400000000
    GROUP BY 
        "type", "addresses"
),
FINAL_BALANCES AS (
    SELECT 
        COALESCE(O."address_type", I."address_type") AS "address_type",
        COALESCE(O."address", I."address") AS "address",
        COALESCE(O."total_output_value", 0) - COALESCE(I."total_input_value", 0) AS "net_balance"
    FROM 
        OUTPUTS_SUMMARY O
    FULL OUTER JOIN 
        INPUTS_SUMMARY I 
    ON 
        O."address" = I."address" 
        AND O."address_type" = I."address_type"
)
SELECT 
    "address_type", 
    MAX("net_balance") AS "max_balance", 
    MIN("net_balance") AS "min_balance"
FROM 
    FINAL_BALANCES
GROUP BY 
    "address_type";