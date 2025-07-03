WITH DAILY_RUNNING_BALANCE AS (
    -- Calculate the daily running balance for each customer
    SELECT 
        "customer_id",
        "txn_date",
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE -"txn_amount" END) 
        OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
DAILY_30_DAY_AVG AS (
    -- Calculate the 30-day rolling average for each customer; treat negative averages as zero
    SELECT 
        "customer_id",
        "txn_date",
        CASE 
            WHEN AVG(running_balance) 
                 OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) < 0 
            THEN 0
            ELSE AVG(running_balance) 
                 OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
        END AS rolling_30d_avg
    FROM 
        DAILY_RUNNING_BALANCE
),
MONTHLY_MAX_30_DAY_AVG AS (
    -- Group daily rolling averages by month and get the maximum 30-day average for each customer per month
    SELECT 
        "customer_id",
        TO_CHAR(DATE_TRUNC('MONTH', TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM') AS month,
        MAX(rolling_30d_avg) AS max_30d_avg
    FROM 
        DAILY_30_DAY_AVG
    GROUP BY 
        "customer_id", 
        DATE_TRUNC('MONTH', TO_DATE("txn_date", 'YYYY-MM-DD'))
),
EXCLUDE_BASELINE_MONTH AS (
    -- Identify and exclude each customer's first month from the data
    SELECT 
        m.* 
    FROM 
        MONTHLY_MAX_30_DAY_AVG m
    JOIN (
        SELECT 
            "customer_id",
            MIN(DATE_TRUNC('MONTH', TO_DATE("txn_date", 'YYYY-MM-DD'))) AS first_month
        FROM 
            "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
        GROUP BY 
            "customer_id"
    ) baseline
    ON 
        m."customer_id" = baseline."customer_id" AND 
        DATE_TRUNC('MONTH', TO_DATE(CONCAT(m.month, '-01'), 'YYYY-MM-DD')) != baseline.first_month
),
MONTHLY_SUM_MAX_AVG AS (
    -- For each month, sum up the maximum 30-day average balances across all customers
    SELECT 
        month,
        SUM(max_30d_avg) AS total_max_30d_avg
    FROM 
        EXCLUDE_BASELINE_MONTH
    GROUP BY 
        month
)
-- Output the final result: monthly totals of summed maximum 30-day average balances
SELECT 
    month,
    total_max_30d_avg
FROM 
    MONTHLY_SUM_MAX_AVG
ORDER BY 
    month;