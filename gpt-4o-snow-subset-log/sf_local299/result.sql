WITH DailyRunningBalances AS (
    -- Step 1: Calculate daily running balances for each customer
    SELECT 
        "customer_id", 
        "txn_date", 
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE -1 * "txn_amount" END) AS "daily_balance",
        SUM(SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE -1 * "txn_amount" END)) 
            OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "running_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id", "txn_date"
),
RollingAverages AS (
    -- Step 2: Compute 30-day rolling average balances, treating negatives as zero
    SELECT 
        "customer_id", 
        "txn_date", 
        GREATEST(AVG("running_balance") 
            OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0) AS "30_day_avg_balance"
    FROM DailyRunningBalances
),
FirstMonthExclusions AS (
    -- Step 3: Identify each customer's first transaction month
    SELECT 
        "customer_id", 
        MIN(LEFT("txn_date", 7)) AS "first_month"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id"
),
MonthlyMaxAverages AS (
    -- Step 4: Calculate maximum 30-day average balance per customer per month, excluding first transaction month
    SELECT 
        RA."customer_id", 
        LEFT(RA."txn_date", 7) AS "month", 
        MAX(RA."30_day_avg_balance") AS "max_30_day_avg_balance"
    FROM RollingAverages RA
    JOIN FirstMonthExclusions FM 
        ON RA."customer_id" = FM."customer_id"
    WHERE LEFT(RA."txn_date", 7) != FM."first_month"
    GROUP BY RA."customer_id", LEFT(RA."txn_date", 7)
)
-- Step 5: Sum the max 30-day average balances across all customers for each month
SELECT 
    "month", 
    SUM("max_30_day_avg_balance") AS "total_max_30_day_avg_balance"
FROM MonthlyMaxAverages
GROUP BY "month"
ORDER BY "month";