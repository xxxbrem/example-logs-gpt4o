WITH transaction_date_range AS (
    -- Step 1: Find the earliest and latest transaction dates per customer
    SELECT 
        "customer_id", 
        MIN("txn_date") AS "earliest_date", 
        MAX("txn_date") AS "latest_date"
    FROM 
        BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    GROUP BY 
        "customer_id"
),
all_dates AS (
    -- Step 2: Generate a row for every customer and every date in their transaction range
    SELECT 
        tdr."customer_id", 
        DATEADD(DAY, SEQ4(), TO_DATE(tdr."earliest_date")) AS "txn_date"
    FROM 
        transaction_date_range tdr,
        TABLE(GENERATOR(ROWCOUNT => 100000)) seq -- Generate sufficient rows for all date spans
    WHERE 
        DATEADD(DAY, SEQ4(), TO_DATE(tdr."earliest_date")) <= TO_DATE(tdr."latest_date")
),
daily_balances AS (
    -- Step 3: Carry forward the daily balances and handle days without transactions
    SELECT 
        ad."customer_id",
        ad."txn_date",
        SUM(COALESCE(ct."txn_amount", 0)) OVER (
            PARTITION BY ad."customer_id" 
            ORDER BY ad."txn_date"
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS "daily_balance"
    FROM 
        all_dates ad
    LEFT JOIN 
        BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS ct
    ON 
        ad."customer_id" = ct."customer_id" AND ad."txn_date" = TO_DATE(ct."txn_date")
),
non_negative_balances AS (
    -- Step 4: Treat negative daily balances as zero
    SELECT
        "customer_id",
        "txn_date",
        GREATEST("daily_balance", 0) AS "daily_balance"
    FROM 
        daily_balances
),
monthly_max_balances AS (
    -- Step 5: Determine the highest daily balance per customer per month
    SELECT
        "customer_id",
        TO_CHAR("txn_date", 'YYYY-MM') AS "month", 
        MAX("daily_balance") AS "max_daily_balance"
    FROM 
        non_negative_balances
    GROUP BY 
        "customer_id", 
        TO_CHAR("txn_date", 'YYYY-MM')
),
monthly_total_balances AS (
    -- Step 6: Aggregate the highest daily balances across all customers for each month
    SELECT
        "month", 
        SUM("max_daily_balance") AS "monthly_total_balance"
    FROM 
        monthly_max_balances
    GROUP BY 
        "month"
)
-- Final Step: Return the monthly total balances
SELECT 
    "month", 
    "monthly_total_balance"
FROM 
    monthly_total_balances
ORDER BY 
    "month" ASC;