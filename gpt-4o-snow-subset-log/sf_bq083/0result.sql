SELECT 
    DATE_FROM_PARTS(
        YEAR(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)), 
        MONTH(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)), 
        DAY(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000))
    ) AS "date",
    TO_CHAR(SUM(
        CASE 
            WHEN "input" LIKE '0x40c10f19%' THEN 
                CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 75, 64), '0')) AS FLOAT) / 1000000
            WHEN "input" LIKE '0x42966c68%' THEN 
                -CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 11, 64), '0')) AS FLOAT) / 1000000
            ELSE 0
        END
    ), 'FM$999,999,999,999,999.00') AS "Δ Total Market Value"
FROM CRYPTO.CRYPTO_ETHEREUM.TRANSACTIONS
WHERE "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
  AND ("input" LIKE '0x40c10f19%' OR "input" LIKE '0x42966c68%')
  AND TO_TIMESTAMP_NTZ("block_timestamp" / 1000000) BETWEEN TO_DATE('2023-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-12-31', 'YYYY-MM-DD')
GROUP BY "date"
ORDER BY "date" DESC NULLS LAST;