WITH DailyBalances AS (
    -- Step 1: Calculate daily balances for each customer, treating negative balances as zero
    SELECT 
        "customer_id", 
        "txn_date"::DATE AS "txn_date",
        CASE WHEN "cumulative_balance" < 0 THEN 0 ELSE "cumulative_balance" END AS "daily_balance"
    FROM (
        SELECT 
            "customer_id", 
            "txn_date", 
            SUM(CASE 
                    WHEN "txn_type" = 'deposit' THEN "txn_amount" 
                    ELSE -1 * "txn_amount" 
                END) OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
            AS "cumulative_balance"
        FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    ) t
),
DateRanges AS (
    -- Step 2: Precompute date ranges for each customer since the number of rows for GENERATOR must be constant
    SELECT 
        "customer_id", 
        "start_date", 
        "end_date", 
        DATEDIFF('day', "start_date", "end_date") + 1 AS "days_count"
    FROM (
        SELECT 
            "customer_id", 
            MIN("txn_date")::DATE AS "start_date", 
            MAX("txn_date")::DATE AS "end_date"
        FROM DailyBalances
        GROUP BY "customer_id"
    )
),
GeneratedDates AS (
    -- Step 3: Generate a continuous date range for each customer
    SELECT
        r."customer_id",
        DATEADD('day', SEQ4(), r."start_date") AS "generated_date"
    FROM DateRanges r
    JOIN TABLE(GENERATOR(ROWCOUNT => 100000)) g -- A sufficiently large ROWCOUNT to handle any reasonable range
    ON SEQ4() < r."days_count"
),
BalanceWithGapsFilled AS (
    -- Step 4: Fill in missing dates for each customer between their min and max transaction dates
    SELECT
        g."customer_id",
        g."generated_date" AS "txn_date",
        COALESCE(b."daily_balance", LAST_VALUE(b."daily_balance") IGNORE NULLS OVER (
            PARTITION BY g."customer_id" ORDER BY g."generated_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )) AS "filled_balance"
    FROM GeneratedDates g
    LEFT JOIN DailyBalances b 
    ON g."customer_id" = b."customer_id" AND g."generated_date" = b."txn_date"
),
MonthlyMaxBalances AS (
    -- Step 5: Determine the highest daily balance each customer had during each month
    SELECT 
        "customer_id",
        TO_CHAR("txn_date", 'YYYY-MM') AS "month", 
        MAX("filled_balance") AS "max_balance"
    FROM BalanceWithGapsFilled
    GROUP BY "customer_id", TO_CHAR("txn_date", 'YYYY-MM')
),
MonthlyTotalBalances AS (
    -- Step 6: Sum the maximum daily balances across all customers for each month
    SELECT 
        "month", 
        SUM("max_balance") AS "monthly_total_balance"
    FROM MonthlyMaxBalances
    GROUP BY "month"
)
-- Step 7: Output the final result
SELECT 
    "month", 
    "monthly_total_balance"
FROM MonthlyTotalBalances
ORDER BY "month";