-- Step 1: Calculate daily balances per customer by summing deposits and subtracting non-deposits
WITH daily_balances AS (
    SELECT 
        "customer_id", 
        TO_DATE("txn_date", 'YYYY-MM-DD') AS "txn_date", -- Cast txn_date to DATE
        SUM(CASE 
                WHEN "txn_type" = 'deposit' THEN "txn_amount" 
                ELSE -"txn_amount" 
            END) AS "daily_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    GROUP BY "customer_id", TO_DATE("txn_date", 'YYYY-MM-DD')
),

-- Step 2: Compute the running daily balance for each customer, ordered chronologically
running_balances AS (
    SELECT 
        "customer_id", 
        "txn_date", 
        SUM("daily_balance") OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS UNBOUNDED PRECEDING) AS "running_balance"
    FROM daily_balances
),

-- Step 3: Calculate the 30-day rolling average balance. Any negative averages are treated as zero.
rolling_averages AS (
    SELECT 
        "customer_id",
        "txn_date",
        GREATEST(
            AVG("running_balance") OVER (
                PARTITION BY "customer_id" 
                ORDER BY "txn_date" 
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
            ), 
            0 -- Replace negative values with zero
        ) AS "30_day_avg_balance"
    FROM running_balances
),

-- Step 4: Compute the baseline (first month) for each customer
baseline_months AS (
    SELECT 
        "customer_id", 
        MIN(DATE_TRUNC('MONTH', "txn_date")) AS "baseline_month"
    FROM daily_balances
    GROUP BY "customer_id"
),

-- Step 5: Extract the year-month from the transaction dates and find the maximum rolling average per customer for each month,
-- excluding the baseline month
max_rolling_avg_per_month AS (
    SELECT 
        r."customer_id", 
        TO_CHAR(DATE_TRUNC('MONTH', r."txn_date"), 'YYYY-MM') AS "month",
        MAX(r."30_day_avg_balance") AS "max_30_day_avg_balance"
    FROM rolling_averages r
    LEFT JOIN baseline_months b
        ON r."customer_id" = b."customer_id"
    WHERE DATE_TRUNC('MONTH', r."txn_date") > b."baseline_month" -- Exclude the baseline month
    GROUP BY r."customer_id", DATE_TRUNC('MONTH', r."txn_date")
),

-- Step 6: Sum these maximum values across all customers for each month
monthly_sums AS (
    SELECT 
        "month",
        SUM("max_30_day_avg_balance") AS "total_max_30_day_avg_balance"
    FROM max_rolling_avg_per_month
    GROUP BY "month"
)

-- Step 7: Present the final result, ordered by month
SELECT 
    "month",
    "total_max_30_day_avg_balance"
FROM monthly_sums
ORDER BY "month";