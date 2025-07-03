SELECT 
    a."ticker",
    a."market_date",
    CASE 
        WHEN b."volume" ILIKE '%K' THEN REPLACE(b."volume", 'K', '')::FLOAT * 1000
        WHEN b."volume" ILIKE '%M' THEN REPLACE(b."volume", 'M', '')::FLOAT * 1000000
        WHEN b."volume" = '-' THEN 0
        ELSE b."volume"::FLOAT
    END AS "previous_volume",
    CASE 
        WHEN a."volume" ILIKE '%K' THEN REPLACE(a."volume", 'K', '')::FLOAT * 1000
        WHEN a."volume" ILIKE '%M' THEN REPLACE(a."volume", 'M', '')::FLOAT * 1000000
        WHEN a."volume" = '-' THEN 0
        ELSE a."volume"::FLOAT
    END AS "current_volume",
    CASE 
        WHEN 
            CASE 
                WHEN b."volume" ILIKE '%K' THEN REPLACE(b."volume", 'K', '')::FLOAT * 1000
                WHEN b."volume" ILIKE '%M' THEN REPLACE(b."volume", 'M', '')::FLOAT * 1000000
                WHEN b."volume" = '-' THEN 0
                ELSE b."volume"::FLOAT
            END = 0 THEN NULL
        ELSE 
            (
                (
                    CASE 
                        WHEN a."volume" ILIKE '%K' THEN REPLACE(a."volume", 'K', '')::FLOAT * 1000
                        WHEN a."volume" ILIKE '%M' THEN REPLACE(a."volume", 'M', '')::FLOAT * 1000000
                        WHEN a."volume" = '-' THEN 0
                        ELSE a."volume"::FLOAT
                    END 
                    - 
                    CASE 
                        WHEN b."volume" ILIKE '%K' THEN REPLACE(b."volume", 'K', '')::FLOAT * 1000
                        WHEN b."volume" ILIKE '%M' THEN REPLACE(b."volume", 'M', '')::FLOAT * 1000000
                        WHEN b."volume" = '-' THEN 0
                        ELSE b."volume"::FLOAT
                    END
                ) / 
                CASE 
                    WHEN b."volume" ILIKE '%K' THEN REPLACE(b."volume", 'K', '')::FLOAT * 1000
                    WHEN b."volume" ILIKE '%M' THEN REPLACE(b."volume", 'M', '')::FLOAT * 1000000
                    WHEN b."volume" = '-' THEN 0
                    ELSE b."volume"::FLOAT
                END
            ) * 100
    END AS "percentage_change_in_volume"
FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES" a
LEFT JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES" b
ON a."ticker" = b."ticker"
   AND TO_DATE(a."market_date", 'DD-MM-YYYY') = TO_DATE(b."market_date", 'DD-MM-YYYY') + INTERVAL '1 DAY'
WHERE TO_DATE(a."market_date", 'DD-MM-YYYY') BETWEEN '2021-08-01' AND '2021-08-10'
  AND 
    CASE 
        WHEN b."volume" ILIKE '%K' THEN REPLACE(b."volume", 'K', '')::FLOAT * 1000
        WHEN b."volume" ILIKE '%M' THEN REPLACE(b."volume", 'M', '')::FLOAT * 1000000
        WHEN b."volume" = '-' THEN 0
        ELSE b."volume"::FLOAT
    END > 0
ORDER BY a."ticker", TO_DATE(a."market_date", 'DD-MM-YYYY')
LIMIT 20;