WITH baseline_exclusion AS (
    -- Determine the baseline (first transaction month) for each customer
    SELECT 
        "customer_id", 
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM') AS "txn_month", 
        TO_CHAR(MIN(TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM') AS "baseline_month"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id", TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM')
),
daily_running_balance AS (
    -- Compute the daily running balance for each customer
    SELECT 
        "customer_id", 
        "txn_date",
        SUM(CASE 
                WHEN "txn_type" = 'deposit' THEN "txn_amount" 
                ELSE -1 * "txn_amount" 
            END) 
        OVER (PARTITION BY "customer_id" ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD')) AS "daily_running_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
rolling_avg_within_month AS (
    -- Calculate the 30-day rolling average balance, treating negative balances as 0
    SELECT 
        "customer_id", 
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM') AS "txn_month", 
        GREATEST(AVG("daily_running_balance") 
                 OVER (PARTITION BY "customer_id" 
                       ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD') 
                       ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0) AS "30_day_rolling_avg_balance"
    FROM daily_running_balance
),
monthly_max_per_customer AS (
    -- Get the maximum 30-day rolling average balance per customer for each month, excluding baseline month
    SELECT 
        r."customer_id", 
        r."txn_month", 
        MAX(r."30_day_rolling_avg_balance") AS "max_30_day_avg_balance"
    FROM rolling_avg_within_month r
    JOIN baseline_exclusion b 
        ON r."customer_id" = b."customer_id"
    WHERE r."txn_month" != b."baseline_month"
    GROUP BY r."customer_id", r."txn_month"
)
-- Sum the maximum values across all customers for each month
SELECT 
    "txn_month", 
    SUM("max_30_day_avg_balance") AS "total_max_30_day_avg_balance"
FROM monthly_max_per_customer
GROUP BY "txn_month"
ORDER BY "txn_month";