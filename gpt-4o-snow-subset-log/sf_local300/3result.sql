WITH customer_date_ranges AS (
  -- Step 1: Determine the earliest and latest transaction dates for each customer
  SELECT 
      "customer_id", 
      MIN(TO_DATE("txn_date", 'YYYY-MM-DD')) AS "earliest_txn_date", 
      MAX(TO_DATE("txn_date", 'YYYY-MM-DD')) AS "latest_txn_date"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
  GROUP BY "customer_id"
),
all_dates AS (
  -- Step 2: Generate all dates for each customer between their earliest and latest transaction dates
  SELECT 
      r."customer_id", 
      DATEADD(DAY, SEQ4(), r."earliest_txn_date") AS "txn_date"
  FROM customer_date_ranges r
  JOIN TABLE(GENERATOR(ROWCOUNT => 10000)) g -- Generate sufficient rows for all date ranges
  WHERE DATEADD(DAY, SEQ4(), r."earliest_txn_date") <= r."latest_txn_date"
),
daily_balances AS (
  -- Step 3: Calculate daily balances, considering days without transactions
  SELECT 
      d."customer_id", 
      d."txn_date", 
      SUM(COALESCE(t."txn_amount", 0)) 
        OVER (PARTITION BY d."customer_id" ORDER BY d."txn_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "daily_balance"
  FROM all_dates d
  LEFT JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS" t
  ON d."customer_id" = t."customer_id" AND d."txn_date" = TO_DATE(t."txn_date", 'YYYY-MM-DD')
),
monthly_max_balances AS (
  -- Step 4: Calculate the highest daily balance for each customer in each month
  SELECT 
      "customer_id", 
      EXTRACT(YEAR FROM "txn_date") AS "txn_year",
      EXTRACT(MONTH FROM "txn_date") AS "txn_month",
      MAX(CASE WHEN "daily_balance" < 0 THEN 0 ELSE "daily_balance" END) AS "max_daily_balance"
  FROM daily_balances
  GROUP BY "customer_id", "txn_year", "txn_month"
)
-- Step 5: Summarize the highest daily balances across all customers by month
SELECT 
    "txn_year", 
    "txn_month", 
    SUM("max_daily_balance") AS "monthly_total_highest_balance"
FROM monthly_max_balances
GROUP BY "txn_year", "txn_month"
ORDER BY "txn_year", "txn_month";