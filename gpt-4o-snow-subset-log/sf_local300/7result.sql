WITH customer_txn_dates AS (
    -- Step 1: Identify each customer's earliest and latest transaction dates.
    SELECT 
        "customer_id",
        MIN(TO_DATE("txn_date")) AS "earliest_txn_date",
        MAX(TO_DATE("txn_date")) AS "latest_txn_date"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    GROUP BY "customer_id"
),
all_dates AS (
    -- Step 2: Generate a continuous series of dates for each customer between their earliest and latest transaction dates.
    SELECT 
        c."customer_id",
        DATEADD(DAY, SEQ4(), c."earliest_txn_date") AS "txn_date"
    FROM customer_txn_dates c,
    TABLE(GENERATOR(ROWCOUNT => 10000)) -- Adjust ROWCOUNT if necessary for a sufficient date range
    WHERE DATEADD(DAY, SEQ4(), c."earliest_txn_date") <= c."latest_txn_date"
),
customer_balances AS (
    -- Step 3: Calculate the daily balance for every transaction day.
    SELECT 
        "customer_id",
        TO_DATE("txn_date") AS "txn_date",
        SUM(CASE 
            WHEN "txn_type" = 'deposit' THEN "txn_amount"
            WHEN "txn_type" = 'withdrawal' THEN -1 * "txn_amount"
            ELSE 0
        END) AS "daily_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    GROUP BY "customer_id", TO_DATE("txn_date")
),
daily_balances_filled AS (
    -- Step 4: Fill in days without transactions by carrying forward the previous day's balance.
    SELECT 
        a."customer_id",
        a."txn_date",
        GREATEST(0, SUM(COALESCE(b."daily_balance", 0)) 
        OVER (PARTITION BY a."customer_id" ORDER BY a."txn_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS "rolling_balance"
    FROM all_dates a
    LEFT JOIN customer_balances b
    ON a."customer_id" = b."customer_id" AND a."txn_date" = b."txn_date"
),
monthly_max_balances AS (
    -- Step 5: Identify the highest rolling balance for each customer in each month.
    SELECT 
        "customer_id",
        DATE_TRUNC('MONTH', "txn_date") AS "month",
        MAX("rolling_balance") AS "max_monthly_balance"
    FROM daily_balances_filled
    GROUP BY "customer_id", DATE_TRUNC('MONTH', "txn_date")
),
monthly_total_balances AS (
    -- Step 6: Sum these maximum monthly balances across all customers for each month.
    SELECT 
        "month",
        SUM("max_monthly_balance") AS "total_max_monthly_balance"
    FROM monthly_max_balances
    GROUP BY "month"
)
-- Step 7: Final output - monthly total maximum balances.
SELECT 
    "month",
    "total_max_monthly_balance"
FROM monthly_total_balances
ORDER BY "month";