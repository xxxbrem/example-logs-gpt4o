WITH MonthlyBalances AS (
    SELECT 
        "customer_id",
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM') AS "txn_month", 
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) AS "total_deposit",
        SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "total_withdrawal",
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) - 
        SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    WHERE 
        "txn_date" LIKE '2020%'
    GROUP BY 
        "customer_id", 
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM')
),
PositiveBalanceCounts AS (
    SELECT 
        "txn_month",
        COUNT(DISTINCT "customer_id") AS "positive_balance_count"
    FROM 
        MonthlyBalances
    WHERE 
        "month_end_balance" > 0
    GROUP BY 
        "txn_month"
),
BalanceExtremes AS (
    SELECT 
        MAX("positive_balance_count") AS "max_count",
        MIN("positive_balance_count") AS "min_count"
    FROM 
        PositiveBalanceCounts
),
MonthsWithExtremes AS (
    SELECT 
        p1."txn_month" AS "max_month",
        p2."txn_month" AS "min_month"
    FROM 
        PositiveBalanceCounts p1
    INNER JOIN BalanceExtremes b1 ON p1."positive_balance_count" = b1."max_count"
    CROSS JOIN 
        PositiveBalanceCounts p2
    INNER JOIN BalanceExtremes b2 ON p2."positive_balance_count" = b2."min_count"
),
AverageBalances AS (
    SELECT 
        mwe."max_month",
        mwe."min_month",
        (SELECT AVG(mb."month_end_balance") 
         FROM MonthlyBalances mb 
         WHERE mb."txn_month" = mwe."max_month") AS "avg_max_month_balance",
        (SELECT AVG(mb."month_end_balance") 
         FROM MonthlyBalances mb 
         WHERE mb."txn_month" = mwe."min_month") AS "avg_min_month_balance"
    FROM 
        MonthsWithExtremes mwe
)
SELECT 
    "avg_max_month_balance", 
    "avg_min_month_balance", 
    ("avg_max_month_balance" - "avg_min_month_balance") AS "balance_difference"
FROM 
    AverageBalances;