WITH customer_first_month AS (
    -- Step 1: Determine the baseline month for each customer
    SELECT 
        "customer_id", 
        TO_CHAR(MIN(TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM') AS "baseline_month"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id"
),
daily_running_balance AS (
    -- Step 2: Compute the daily running balance for each customer
    SELECT
        "customer_id",
        TO_DATE("txn_date", 'YYYY-MM-DD') AS "txn_date",
        SUM(
            CASE 
                WHEN "txn_type" ILIKE 'deposit' THEN "txn_amount"
                ELSE -1 * "txn_amount"
            END
        ) OVER (
            PARTITION BY "customer_id" 
            ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD')
        ) AS "daily_running_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
rolling_30_day_avg AS (
    -- Step 3: Calculate the 30-day rolling average balance (treat negative averages as zero)
    SELECT
        d."customer_id",
        d."txn_date",
        GREATEST(
            0, 
            AVG(d."daily_running_balance") OVER (
                PARTITION BY d."customer_id" 
                ORDER BY d."txn_date" 
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
            )
        ) AS "30_day_avg_balance"
    FROM daily_running_balance d
),
monthly_max_30_day_avg AS (
    -- Step 4: Group by month and find the max 30-day average balance for each customer
    SELECT
        r."customer_id",
        TO_CHAR(r."txn_date", 'YYYY-MM') AS "txn_month",
        MAX(r."30_day_avg_balance") AS "max_30_day_avg_balance"
    FROM rolling_30_day_avg r
    GROUP BY r."customer_id", TO_CHAR(r."txn_date", 'YYYY-MM')
),
filtered_data AS (
    -- Step 5: Exclude the first month (baseline) for each customer
    SELECT
        m."txn_month",
        m."customer_id",
        m."max_30_day_avg_balance"
    FROM monthly_max_30_day_avg m
    JOIN customer_first_month cfm
    ON m."customer_id" = cfm."customer_id"
    WHERE m."txn_month" != cfm."baseline_month"
),
monthly_totals AS (
    -- Step 6: Sum the max 30-day average balances across all customers for each month
    SELECT
        f."txn_month",
        SUM(f."max_30_day_avg_balance") AS "total_max_30_day_avg_balance"
    FROM filtered_data f
    GROUP BY f."txn_month"
)
-- Step 7: Output the final results
SELECT 
    "txn_month", 
    "total_max_30_day_avg_balance"
FROM monthly_totals
ORDER BY "txn_month";