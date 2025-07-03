WITH MonthlyBalances AS (
    SELECT "customer_id", 
           LEFT("txn_date", 7) AS "transaction_month", 
           SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE 0 END) - 
           SUM(CASE WHEN "txn_type" = 'withdrawal' THEN "txn_amount" ELSE 0 END) AS "month_end_balance"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    WHERE LEFT("txn_date", 4) = '2020'
    GROUP BY "customer_id", LEFT("txn_date", 7)
),
PositiveBalancesByMonth AS (
    SELECT "transaction_month", 
           COUNT(DISTINCT "customer_id") AS "positive_balance_customers"
    FROM MonthlyBalances
    WHERE "month_end_balance" > 0
    GROUP BY "transaction_month"
),
MostAndLeastPositiveMonths AS (
    SELECT "transaction_month", "positive_balance_customers"
    FROM PositiveBalancesByMonth
    WHERE "positive_balance_customers" = (SELECT MAX("positive_balance_customers") FROM PositiveBalancesByMonth)
       OR "positive_balance_customers" = (SELECT MIN("positive_balance_customers") FROM PositiveBalancesByMonth)
)
SELECT MAX("average_balance") - MIN("average_balance") AS "difference_in_average_balances"
FROM (
    SELECT "transaction_month", 
           AVG("month_end_balance") AS "average_balance"
    FROM MonthlyBalances
    WHERE "transaction_month" IN (SELECT "transaction_month" FROM MostAndLeastPositiveMonths)
    GROUP BY "transaction_month"
) AS Averages;