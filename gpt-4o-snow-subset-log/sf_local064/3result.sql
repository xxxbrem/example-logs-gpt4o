WITH monthly_balances AS (
    SELECT 
        "customer_id", 
        SUBSTR("txn_date", 1, 7) AS "month", -- Extract month (YYYY-MM) from transaction date
        SUM(CASE 
                WHEN "txn_type" = 'deposit' THEN "txn_amount" 
                ELSE -1 * "txn_amount" 
            END) AS "month_end_balance" -- Calculate month-end balance by summing deposits and subtracting withdrawals
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    WHERE 
        "txn_date" LIKE '2020-%' -- Filter transactions only for 2020
    GROUP BY 
        "customer_id", SUBSTR("txn_date", 1, 7) -- Group by customer and month
),
positive_balances AS (
    SELECT 
        "month", 
        COUNT(DISTINCT "customer_id") AS "positive_balance_count", -- Count customers with positive balances
        AVG("month_end_balance") AS "average_balance" -- Calculate average balance for each month
    FROM 
        monthly_balances
    WHERE 
        "month_end_balance" > 0 -- Only consider customers with positive balances
    GROUP BY 
        "month"
),
most_and_fewest_customers AS (
    SELECT 
        "month", 
        "average_balance",
        ROW_NUMBER() OVER (ORDER BY "positive_balance_count" DESC) AS "most_customers_rank", -- Rank months with most customers
        ROW_NUMBER() OVER (ORDER BY "positive_balance_count" ASC) AS "fewest_customers_rank" -- Rank months with fewest customers
    FROM 
        positive_balances
)
SELECT 
    (SELECT "average_balance" 
     FROM most_and_fewest_customers 
     WHERE "most_customers_rank" = 1) - 
    (SELECT "average_balance" 
     FROM most_and_fewest_customers 
     WHERE "fewest_customers_rank" = 1) AS "difference" -- Calculate the difference in average balances
FROM 
    dual;