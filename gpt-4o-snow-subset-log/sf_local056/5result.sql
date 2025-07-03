WITH MonthlyPayments AS (
    SELECT 
        "customer_id",
        DATE_TRUNC('MONTH', TO_TIMESTAMP("payment_date", 'YYYY-MM-DD HH24:MI:SS.FF3')) AS "payment_month",
        SUM("amount") AS "monthly_total"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT
    GROUP BY "customer_id", DATE_TRUNC('MONTH', TO_TIMESTAMP("payment_date", 'YYYY-MM-DD HH24:MI:SS.FF3'))
), 
MonthlyChanges AS (
    SELECT 
        "customer_id",
        "payment_month",
        "monthly_total",
        LEAD("monthly_total") OVER (PARTITION BY "customer_id" ORDER BY "payment_month") - "monthly_total" AS "monthly_change"
    FROM MonthlyPayments
),
AverageChanges AS (
    SELECT 
        "customer_id",
        AVG(ABS("monthly_change")) AS "avg_monthly_change"
    FROM MonthlyChanges
    WHERE "monthly_change" IS NOT NULL
    GROUP BY "customer_id"
),
HighestChangeCustomer AS (
    SELECT 
        "customer_id"
    FROM AverageChanges
    ORDER BY "avg_monthly_change" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    C."first_name",
    C."last_name"
FROM HighestChangeCustomer H
JOIN SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER C
ON H."customer_id" = C."customer_id";