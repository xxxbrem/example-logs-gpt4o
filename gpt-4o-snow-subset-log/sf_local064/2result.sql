WITH MonthlyBalances AS (
    -- Step 1: Compute the month-end balance for each customer and each month in 2020
    SELECT 
        "customer_id", 
        LEFT("txn_date", 7) AS "txn_month", -- Extract year-month for grouping
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) -
        SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    WHERE "txn_date" LIKE '2020-%' -- Only include transactions from 2020
    GROUP BY "customer_id", LEFT("txn_date", 7)
), 
PositiveBalanceCounts AS (
    -- Step 2: Identify the count of customers with a positive balance for each month
    SELECT 
        "txn_month", 
        COUNT(DISTINCT "customer_id") AS "positive_balance_customers"
    FROM MonthlyBalances
    WHERE "month_end_balance" > 0
    GROUP BY "txn_month"
),
HighestMonth AS (
    -- Step 3a: Find the month with the highest count of positive-balance customers
    SELECT 
        "txn_month" AS "month", 
        "positive_balance_customers"
    FROM PositiveBalanceCounts
    ORDER BY "positive_balance_customers" DESC 
    LIMIT 1
),
LowestMonth AS (
    -- Step 3b: Find the month with the lowest count of positive-balance customers
    SELECT 
        "txn_month" AS "month", 
        "positive_balance_customers"
    FROM PositiveBalanceCounts
    ORDER BY "positive_balance_customers" ASC 
    LIMIT 1
),
AverageBalances AS (
    -- Step 4: Compute the average month-end balance for the highest and lowest months
    SELECT 
        "txn_month", 
        AVG("month_end_balance") AS "average_positive_balance"
    FROM MonthlyBalances
    WHERE "txn_month" IN (
        (SELECT "month" FROM HighestMonth),
        (SELECT "month" FROM LowestMonth)
    )
    AND "month_end_balance" > 0
    GROUP BY "txn_month"
)
-- Step 5: Compute the difference between the two averages
SELECT 
    MAX(CASE WHEN "txn_month" = (SELECT "month" FROM HighestMonth) THEN "average_positive_balance" ELSE NULL END) -
    MAX(CASE WHEN "txn_month" = (SELECT "month" FROM LowestMonth) THEN "average_positive_balance" ELSE NULL END) AS "average_balance_difference"
FROM AverageBalances;