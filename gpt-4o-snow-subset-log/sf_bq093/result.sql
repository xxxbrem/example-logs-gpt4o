WITH TRANSACTIONS_WITH_FEES AS (
    SELECT
        "from_address" AS address,
        -("value" + ("gas_price" * COALESCE("receipt_gas_used", 0))) AS net_change
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE "receipt_status" = 1 -- Only include successful transactions
        AND "block_timestamp" >= 1476403200000000 -- Start of October 14, 2016 (UTC)
        AND "block_timestamp" < 1476489600000000  -- End of October 14, 2016 (UTC)

    UNION ALL

    SELECT
        "to_address" AS address,
        "value" AS net_change
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE "receipt_status" = 1 -- Only include successful transactions
        AND "block_timestamp" >= 1476403200000000 -- Start of October 14, 2016 (UTC)
        AND "block_timestamp" < 1476489600000000  -- End of October 14, 2016 (UTC)

    UNION ALL

    SELECT
        blk."miner" AS address,
        SUM(COALESCE(trx."receipt_gas_used", 0) * trx."gas_price") AS net_change
    FROM CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS trx
    JOIN CRYPTO.CRYPTO_ETHEREUM_CLASSIC.BLOCKS blk
        ON trx."block_number" = blk."number"
    WHERE trx."receipt_status" = 1 -- Only include successful transactions
        AND trx."block_timestamp" >= 1476403200000000 -- Start of October 14, 2016 (UTC)
        AND trx."block_timestamp" < 1476489600000000  -- End of October 14, 2016 (UTC)
    GROUP BY blk."miner"
)

SELECT
    MAX(total_net_change) AS max_net_change,
    MIN(total_net_change) AS min_net_change
FROM (
    SELECT
        address,
        SUM(net_change) AS total_net_change
    FROM TRANSACTIONS_WITH_FEES
    GROUP BY address
) AS address_changes;