WITH monthly_balances AS (
    SELECT 
        "customer_id", 
        TO_CHAR(TO_DATE("txn_date"), 'YYYY-MM') AS "txn_month",
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) -
        SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    WHERE "txn_date" LIKE '2020-%'
    GROUP BY "customer_id", TO_CHAR(TO_DATE("txn_date"), 'YYYY-MM')
),
positive_balance_counts AS (
    SELECT 
        "txn_month", 
        COUNT(DISTINCT "customer_id") AS "positive_balance_customer_count"
    FROM monthly_balances
    WHERE "month_end_balance" > 0
    GROUP BY "txn_month"
),
target_months AS (
    SELECT 
        MAX("positive_balance_customer_count") AS "max_positive_count",
        MIN("positive_balance_customer_count") AS "min_positive_count"
    FROM positive_balance_counts
),
selected_months AS (
    SELECT 
        pb."txn_month",
        AVG(mb."month_end_balance") AS "avg_month_end_balance"
    FROM positive_balance_counts pb
    JOIN target_months tm ON pb."positive_balance_customer_count" = tm."max_positive_count" 
                            OR pb."positive_balance_customer_count" = tm."min_positive_count"
    JOIN monthly_balances mb ON pb."txn_month" = mb."txn_month"
    GROUP BY pb."txn_month"
),
balance_difference AS (
    SELECT 
        MAX("avg_month_end_balance") AS "max_average",
        MIN("avg_month_end_balance") AS "min_average"
    FROM selected_months
)
SELECT 
    "max_average" - "min_average" AS "average_balance_difference"
FROM balance_difference;