WITH CTE_RUNNING_BALANCE AS (
    -- Calculate the running balance for each customer
    SELECT 
        "customer_id",
        TO_DATE("txn_date", 'YYYY-MM-DD') AS "txn_date", -- Convert txn_date to DATE type
        SUM(SUM(CASE 
            WHEN "txn_type" ILIKE 'deposit' THEN "txn_amount" 
            ELSE -1 * "txn_amount" 
        END)) 
        OVER (PARTITION BY "customer_id" ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD') ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "running_balance"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY 
        "customer_id", 
        "txn_date", 
        "txn_type", 
        "txn_amount"
),
CTE_30_DAY_AVERAGE AS (
    -- Compute the 30-day rolling average, treating negative balances as 0
    SELECT 
        "customer_id",
        "txn_date",
        COALESCE(AVG("running_balance") 
            OVER (PARTITION BY "customer_id" ORDER BY "txn_date" ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0) AS "rolling_30_day_avg"
    FROM 
        CTE_RUNNING_BALANCE
),
CTE_CLEANED_AVERAGE AS (
    -- Treat negative rolling averages as 0
    SELECT 
        "customer_id",
        "txn_date",
        DATE_TRUNC('MONTH', "txn_date") AS "txn_month",
        CASE WHEN "rolling_30_day_avg" < 0 THEN 0 ELSE "rolling_30_day_avg" END AS "cleaned_30_day_avg"
    FROM 
        CTE_30_DAY_AVERAGE
),
CTE_MAX_30_DAY_AVERAGE_BY_MONTH AS (
    -- Find the maximum 30-day average for each customer within each month
    SELECT 
        "customer_id",
        "txn_month",
        MAX("cleaned_30_day_avg") AS "max_30_day_avg"
    FROM 
        CTE_CLEANED_AVERAGE
    GROUP BY 
        "customer_id", 
        "txn_month"
),
CTE_EXCLUDING_BASELINE AS (
    -- Exclude the first month of each customer’s transaction history (baseline)
    SELECT 
        a."customer_id",
        a."txn_month",
        a."max_30_day_avg"
    FROM 
        CTE_MAX_30_DAY_AVERAGE_BY_MONTH a
    LEFT JOIN (
        -- Find the first month of each customer
        SELECT 
            "customer_id",
            MIN("txn_month") AS "baseline_month"
        FROM 
            CTE_CLEANED_AVERAGE
        GROUP BY 
            "customer_id"
    ) b
    ON a."customer_id" = b."customer_id" AND a."txn_month" = b."baseline_month"
    WHERE b."baseline_month" IS NULL OR a."txn_month" <> b."baseline_month"
),
CTE_SUM_BY_MONTH AS (
    -- Sum the maximum 30-day averages across all customers for each month
    SELECT 
        "txn_month",
        SUM("max_30_day_avg") AS "monthly_total"
    FROM 
        CTE_EXCLUDING_BASELINE
    GROUP BY 
        "txn_month"
)
-- Final result: Monthly totals of summed maximum 30-day averages (excluding baseline months)
SELECT 
    "txn_month",
    "monthly_total"
FROM 
    CTE_SUM_BY_MONTH
ORDER BY 
    "txn_month";