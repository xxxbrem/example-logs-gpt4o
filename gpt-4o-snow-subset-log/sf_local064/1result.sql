WITH MonthlyBalances AS (
    -- Calculate month-end balances for each customer and each month in 2020
    SELECT 
        "customer_id",
        LEFT("txn_date", 7) AS "month",
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) 
          - SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    WHERE "txn_date" LIKE '2020-%'
    GROUP BY "customer_id", LEFT("txn_date", 7)
),
MonthlyPositiveBalances AS (
    -- Count customers with positive month-end balances per month
    SELECT 
        "month",
        COUNT(*) AS "positive_balance_customer_count",
        AVG("month_end_balance") AS "average_balance"
    FROM MonthlyBalances
    WHERE "month_end_balance" > 0
    GROUP BY "month"
),
MaxPositiveMonth AS (
    -- Get the month with the maximum count of positive balance customers
    SELECT 
        "month" AS "max_positive_month", 
        "average_balance" AS "max_avg_balance"
    FROM MonthlyPositiveBalances
    QUALIFY ROW_NUMBER() OVER (ORDER BY "positive_balance_customer_count" DESC) = 1
),
MinPositiveMonth AS (
    -- Get the month with the minimum count of positive balance customers
    SELECT 
        "month" AS "min_positive_month", 
        "average_balance" AS "min_avg_balance"
    FROM MonthlyPositiveBalances
    QUALIFY ROW_NUMBER() OVER (ORDER BY "positive_balance_customer_count" ASC) = 1
)
-- Compute the difference between the two averages
SELECT 
    MaxPositiveMonth."max_avg_balance",
    MinPositiveMonth."min_avg_balance",
    MaxPositiveMonth."max_avg_balance" - MinPositiveMonth."min_avg_balance" AS "difference_in_averages"
FROM MaxPositiveMonth, MinPositiveMonth;