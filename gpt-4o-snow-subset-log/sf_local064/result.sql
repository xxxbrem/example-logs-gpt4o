WITH CTE_MONTHLY_BALANCES AS (
    -- Step 1: Calculate month-end balance for each customer and month
    SELECT 
        "customer_id",
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM') AS "txn_month",
        SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) - 
        SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.CUSTOMER_TRANSACTIONS
    WHERE TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY') = '2020'
    GROUP BY "customer_id", TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY-MM')
),
CTE_MONTHLY_POSITIVE_BALANCES AS (
    -- Step 2: Count customers with a positive balance for each month
    SELECT 
        "txn_month",
        COUNT(DISTINCT "customer_id") AS "positive_balance_customer_count"
    FROM CTE_MONTHLY_BALANCES
    WHERE "month_end_balance" > 0
    GROUP BY "txn_month"
),
CTE_HIGHEST_AND_LOWEST_MONTH AS (
    -- Step 3: Identify the months with the highest and lowest positive balance customer counts
    SELECT 
        (SELECT "txn_month" FROM CTE_MONTHLY_POSITIVE_BALANCES ORDER BY "positive_balance_customer_count" DESC NULLS LAST LIMIT 1) AS "max_month",
        (SELECT "txn_month" FROM CTE_MONTHLY_POSITIVE_BALANCES ORDER BY "positive_balance_customer_count" ASC NULLS LAST LIMIT 1) AS "min_month"
),
CTE_AVERAGE_BALANCES AS (
    -- Step 4: Calculate the average month-end balance for the identified months
    SELECT 
        AVG("month_end_balance") AS "average_balance_max_month",
        NULL AS "average_balance_min_month"
    FROM CTE_MONTHLY_BALANCES, CTE_HIGHEST_AND_LOWEST_MONTH
    WHERE "txn_month" = (SELECT "max_month" FROM CTE_HIGHEST_AND_LOWEST_MONTH)
    
    UNION ALL
    
    SELECT 
        NULL AS "average_balance_max_month",
        AVG("month_end_balance") AS "average_balance_min_month"
    FROM CTE_MONTHLY_BALANCES, CTE_HIGHEST_AND_LOWEST_MONTH
    WHERE "txn_month" = (SELECT "min_month" FROM CTE_HIGHEST_AND_LOWEST_MONTH)
)
-- Step 5: Calculate the difference between the average balances
SELECT 
    MAX("average_balance_max_month") - MAX("average_balance_min_month") AS "difference_in_average_balance"
FROM CTE_AVERAGE_BALANCES;