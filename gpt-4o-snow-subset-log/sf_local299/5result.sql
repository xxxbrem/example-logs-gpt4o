WITH Daily_Running_Balance AS (
    SELECT 
        "customer_id", 
        "txn_date", 
        SUM(
            CASE 
                WHEN "txn_type" = 'deposit' THEN "txn_amount"
                ELSE -1 * "txn_amount" 
            END
        ) OVER (PARTITION BY "customer_id" ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD') ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "daily_running_balance"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
Rolling_30_Day_Avg AS (
    SELECT 
        "customer_id", 
        "txn_date", 
        CASE 
            WHEN AVG("daily_running_balance") OVER (
                PARTITION BY "customer_id" 
                ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD') 
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
            ) < 0 THEN 0 
            ELSE AVG("daily_running_balance") OVER (
                PARTITION BY "customer_id" 
                ORDER BY TO_DATE("txn_date", 'YYYY-MM-DD') 
                ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
            )
        END AS "30_day_rolling_avg_balance"
    FROM 
        Daily_Running_Balance
),
Monthly_Max_Per_Customer AS (
    SELECT 
        "customer_id", 
        TO_CHAR(DATE_TRUNC('month', TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM') AS "month_period", 
        MAX("30_day_rolling_avg_balance") AS "monthly_max_30_day_avg"
    FROM 
        Rolling_30_Day_Avg
    GROUP BY 
        "customer_id", 
        TO_CHAR(DATE_TRUNC('month', TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM')
),
Customer_Baseline AS (
    SELECT 
        "customer_id", 
        MIN(TO_CHAR(DATE_TRUNC('month', TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM')) AS "baseline_month"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY 
        "customer_id"
)
SELECT 
    m."month_period", 
    SUM(m."monthly_max_30_day_avg") AS "sum_max_30_day_avg_all_customers"
FROM 
    Monthly_Max_Per_Customer m
LEFT JOIN 
    Customer_Baseline b
ON 
    m."customer_id" = b."customer_id"
WHERE 
    m."month_period" != b."baseline_month"
GROUP BY 
    m."month_period"
ORDER BY 
    m."month_period"