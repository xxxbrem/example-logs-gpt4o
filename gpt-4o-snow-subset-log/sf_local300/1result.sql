WITH customer_date_range AS (
    -- Step 1: Determine the earliest and latest transaction dates for each customer
    SELECT 
        "customer_id", 
        MIN("txn_date")::DATE AS "earliest_txn_date", 
        MAX("txn_date")::DATE AS "latest_txn_date"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY 
        "customer_id"
),
date_series AS (
    -- Step 2: Generate a date series for each customer between their earliest and latest transaction dates
    SELECT 
        cdr."customer_id", 
        dateadd('DAY', seq4(), cdr."earliest_txn_date") AS "all_dates"
    FROM 
        customer_date_range cdr, 
        TABLE(generator(ROWCOUNT => 1000000)) -- Generate sufficient rows
    WHERE 
        dateadd('DAY', seq4(), cdr."earliest_txn_date") <= cdr."latest_txn_date"
),
daily_balances AS (
    -- Step 3: Calculate daily balances and carry forward balances for dates without transactions
    SELECT 
        ds."customer_id", 
        ds."all_dates", 
        SUM(CASE 
                WHEN ct."txn_date" IS NOT NULL THEN ct."txn_amount" 
                ELSE 0 
            END) 
        OVER (
            PARTITION BY ds."customer_id" ORDER BY ds."all_dates" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS "daily_balance"
    FROM 
        date_series ds
        LEFT JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS" ct
        ON ds."customer_id" = ct."customer_id" AND ds."all_dates" = ct."txn_date"::DATE
),
adjusted_balances AS (
    -- Step 4: Adjust daily balances to ensure negative balances are treated as zero
    SELECT 
        "customer_id", 
        "all_dates", 
        CASE 
            WHEN "daily_balance" < 0 THEN 0 
            ELSE "daily_balance" 
        END AS "adjusted_daily_balance"
    FROM 
        daily_balances
),
monthly_max_balances AS (
    -- Step 5: Calculate the highest daily balance for each customer within each month
    SELECT 
        "customer_id", 
        DATE_TRUNC('MONTH', "all_dates") AS "month", 
        MAX("adjusted_daily_balance") AS "max_daily_balance"
    FROM 
        adjusted_balances
    GROUP BY 
        "customer_id", 
        DATE_TRUNC('MONTH', "all_dates")
),
monthly_total_balances AS (
    -- Step 6: Aggregate the highest daily balances of all customers for each month
    SELECT 
        "month", 
        SUM("max_daily_balance") AS "monthly_total_balance"
    FROM 
        monthly_max_balances
    GROUP BY 
        "month"
)
-- Final Output: Monthly total balance across all customers
SELECT 
    "month", 
    "monthly_total_balance"
FROM 
    monthly_total_balances
ORDER BY 
    "month";