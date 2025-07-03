WITH CustomerDateRange AS (
    -- Step 1: Calculate the earliest and latest transaction dates for each customer
    SELECT 
        "customer_id", 
        MIN("txn_date") AS "earliest_txn_date", 
        MAX("txn_date") AS "latest_txn_date"
    FROM 
        BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    GROUP BY 
        "customer_id"
),
DateSeries AS (
    -- Step 2: Generate all dates between the earliest and latest transaction dates for every customer
    SELECT 
        dr."customer_id", 
        DATEADD(DAY, seq.seq_num - 1, TO_DATE(dr."earliest_txn_date")) AS "txn_date"
    FROM 
        CustomerDateRange dr
    JOIN 
        LATERAL (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY NULL) AS seq_num  -- Add an ORDER BY NULL clause
            FROM 
                TABLE(GENERATOR(ROWCOUNT => 10000))
        ) seq
    ON 
        DATEADD(DAY, seq.seq_num - 1, TO_DATE(dr."earliest_txn_date")) <= TO_DATE(dr."latest_txn_date")
),
DailyBalances AS (
    -- Step 3: Merge transaction data with generated date series and calculate running balances
    SELECT
        ds."customer_id",
        ds."txn_date",
        SUM(COALESCE(ct."txn_amount", 0)) OVER (
            PARTITION BY ds."customer_id" 
            ORDER BY ds."txn_date"
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS "running_balance"
    FROM 
        DateSeries ds
    LEFT JOIN 
        BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS ct
    ON 
        ds."customer_id" = ct."customer_id" AND 
        ds."txn_date" = TO_DATE(ct."txn_date")
),
CappedBalances AS (
    -- Step 4: Cap any negative balances at zero
    SELECT 
        "customer_id", 
        "txn_date", 
        CASE 
            WHEN "running_balance" < 0 THEN 0 
            ELSE "running_balance" 
        END AS "daily_balance"
    FROM 
        DailyBalances
),
MaxBalancesByMonth AS (
    -- Step 5: Calculate the maximum daily balance for each customer in each month
    SELECT 
        "customer_id", 
        TO_CHAR("txn_date", 'YYYY-MM') AS "month", 
        MAX("daily_balance") AS "max_daily_balance"
    FROM 
        CappedBalances
    GROUP BY 
        "customer_id", 
        TO_CHAR("txn_date", 'YYYY-MM')
),
MonthlyTotalMaxBalance AS (
    -- Step 6: Sum the maximum daily balances across all customers for each month
    SELECT 
        "month", 
        SUM("max_daily_balance") AS "monthly_total_max_balance"
    FROM 
        MaxBalancesByMonth
    GROUP BY 
        "month"
    ORDER BY 
        "month"
)
-- Step 7: Return the result
SELECT 
    "month", 
    "monthly_total_max_balance"
FROM 
    MonthlyTotalMaxBalance;