WITH MonthlyChanges AS (
    SELECT 
        "customer_id",
        DATE_TRUNC('month', CAST("payment_date" AS TIMESTAMP)) AS month,
        SUM("amount") AS total_monthly_payment,
        LAG(SUM("amount")) OVER (PARTITION BY "customer_id" ORDER BY DATE_TRUNC('month', CAST("payment_date" AS TIMESTAMP))) AS previous_monthly_payment
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT"
    GROUP BY "customer_id", DATE_TRUNC('month', CAST("payment_date" AS TIMESTAMP))
),
MonthlyChangeDifferences AS (
    SELECT
        "customer_id",
        ABS(total_monthly_payment - previous_monthly_payment) AS monthly_change
    FROM MonthlyChanges
    WHERE previous_monthly_payment IS NOT NULL
),
AverageMonthlyChange AS (
    SELECT
        "customer_id",
        AVG(monthly_change) AS avg_monthly_change
    FROM MonthlyChangeDifferences
    GROUP BY "customer_id"
),
CustomerWithMaxChange AS (
    SELECT 
        "customer_id", 
        avg_monthly_change AS max_avg_change
    FROM AverageMonthlyChange
    QUALIFY ROW_NUMBER() OVER (ORDER BY avg_monthly_change DESC) = 1
)
SELECT 
    C."first_name",
    C."last_name"
FROM CustomerWithMaxChange AS M
JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER" AS C
ON M."customer_id" = C."customer_id";