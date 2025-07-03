WITH daily_balances AS (
    SELECT 
        "customer_id", 
        "txn_date", 
        SUM(CASE 
                WHEN "txn_type" = 'deposit' THEN "txn_amount" 
                ELSE - "txn_amount" 
            END) 
            OVER (
                PARTITION BY "customer_id" 
                ORDER BY "txn_date" 
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS "daily_running_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
rolling_30_day_averages AS (
    SELECT
        "customer_id",
        "txn_date",
        GREATEST(
            AVG("daily_running_balance") 
                OVER (
                    PARTITION BY "customer_id" 
                    ORDER BY "txn_date" 
                    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                ), 
            0
        ) AS "30_day_avg_balance"
    FROM daily_balances
),
monthly_max_30_day_avg AS (
    SELECT
        DATE_TRUNC('MONTH', TO_DATE("txn_date")) AS "month",
        "customer_id",
        MAX("30_day_avg_balance") AS "max_30_day_avg_balance"
    FROM rolling_30_day_averages
    WHERE "txn_date" NOT IN (
        SELECT MIN("txn_date")
        FROM daily_balances
        GROUP BY "customer_id"
    ) -- Exclude each customer's first month
    GROUP BY DATE_TRUNC('MONTH', TO_DATE("txn_date")), "customer_id"
),
monthly_totals AS (
    SELECT
        "month",
        SUM("max_30_day_avg_balance") AS "sum_max_30_day_avg_balance"
    FROM monthly_max_30_day_avg
    GROUP BY "month"
)
SELECT * 
FROM monthly_totals
ORDER BY "month";