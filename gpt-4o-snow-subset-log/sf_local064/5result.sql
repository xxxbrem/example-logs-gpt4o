WITH MonthlyBalances AS (
    -- Calculate month-end balance for each customer and month in 2020
    SELECT 
        "customer_id", 
        LEFT("txn_date", 7) AS "txn_month", 
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) 
        - SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS 
    WHERE "txn_date" LIKE '2020-%'
    GROUP BY "customer_id", LEFT("txn_date", 7)
),
PositiveBalanceCounts AS (
    -- Count the number of customers with a positive balance for each month
    SELECT 
        "txn_month", 
        COUNT(CASE WHEN "month_end_balance" > 0 THEN 1 ELSE NULL END) AS "positive_balance_count"
    FROM MonthlyBalances
    GROUP BY "txn_month"
),
MaxMinMonths AS (
    -- Identify the month with the most and the fewest customers having a positive balance
    SELECT 
        (SELECT "txn_month" FROM PositiveBalanceCounts ORDER BY "positive_balance_count" DESC LIMIT 1) AS "max_positive_month",
        (SELECT "txn_month" FROM PositiveBalanceCounts ORDER BY "positive_balance_count" ASC LIMIT 1) AS "min_positive_month"
),
AverageBalances AS (
    -- Calculate the average month-end balance for the identified months
    SELECT 
        AVG("month_end_balance") AS "average_balance", 
        'max_positive_month' AS "month_type"
    FROM MonthlyBalances
    WHERE "txn_month" = (SELECT "max_positive_month" FROM MaxMinMonths)
    UNION ALL
    SELECT 
        AVG("month_end_balance") AS "average_balance", 
        'min_positive_month' AS "month_type"
    FROM MonthlyBalances
    WHERE "txn_month" = (SELECT "min_positive_month" FROM MaxMinMonths)
)
-- Calculate the difference in average balances between these two months
SELECT 
    ABS(
        MAX(CASE WHEN "month_type" = 'max_positive_month' THEN "average_balance" END) 
        - MAX(CASE WHEN "month_type" = 'min_positive_month' THEN "average_balance" END)
    ) AS "average_balance_difference"
FROM AverageBalances;