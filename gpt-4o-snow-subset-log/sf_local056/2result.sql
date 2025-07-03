WITH MonthlyTotals AS (
    SELECT "customer_id", 
           DATE_TRUNC('MONTH', TO_TIMESTAMP("payment_date")) AS "payment_month", 
           SUM("amount") AS "monthly_payment"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT
    GROUP BY "customer_id", "payment_month"
),
MonthlyChanges AS (
    SELECT "customer_id", 
           "payment_month", 
           "monthly_payment", 
           LAG("monthly_payment") OVER (PARTITION BY "customer_id" ORDER BY "payment_month") AS "prev_month_payment"
    FROM MonthlyTotals
),
CustomerChanges AS (
    SELECT "customer_id", 
           AVG(ABS("monthly_payment" - "prev_month_payment")) AS "average_monthly_change"
    FROM MonthlyChanges
    WHERE "prev_month_payment" IS NOT NULL
    GROUP BY "customer_id"
)
SELECT c."first_name", c."last_name", ch."average_monthly_change"
FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c
JOIN CustomerChanges ch ON c."customer_id" = ch."customer_id"
ORDER BY ch."average_monthly_change" DESC NULLS LAST
LIMIT 1;