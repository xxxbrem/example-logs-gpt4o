WITH normalized_volumes AS (
  SELECT "ticker", 
         "market_date", 
         CASE 
           WHEN "volume" ILIKE '%K%' THEN REPLACE("volume", 'K', '')::FLOAT * 1000
           WHEN "volume" ILIKE '%M%' THEN REPLACE("volume", 'M', '')::FLOAT * 1000000
           WHEN "volume" = '-' THEN 0
           ELSE "volume"::FLOAT
         END AS "normalized_volume"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
),
filtered_data AS (
  SELECT *
  FROM normalized_volumes
  WHERE "market_date" BETWEEN '01-08-2021' AND '10-08-2021'
),
previous_day_volumes AS (
  SELECT n1."ticker", n1."market_date", n1."normalized_volume", 
         n2."normalized_volume" AS "previous_day_volume"
  FROM filtered_data n1
  LEFT JOIN filtered_data n2
    ON n1."ticker" = n2."ticker"
    AND TO_DATE(n1."market_date", 'DD-MM-YYYY') = TO_DATE(n2."market_date", 'DD-MM-YYYY') + 1
),
percentage_changes AS (
  SELECT "ticker", 
         "market_date",
         "normalized_volume",
         "previous_day_volume",
         CASE 
           WHEN "previous_day_volume" > 0 THEN 
             (( "normalized_volume" - "previous_day_volume" ) / "previous_day_volume") * 100
           ELSE NULL
         END AS "percentage_change"
  FROM previous_day_volumes
)
SELECT "ticker", 
       "market_date", 
       "normalized_volume", 
       "previous_day_volume", 
       "percentage_change"
FROM percentage_changes
WHERE "percentage_change" IS NOT NULL
ORDER BY "ticker", TO_DATE("market_date", 'DD-MM-YYYY');