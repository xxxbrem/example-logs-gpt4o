WITH MonthlyPayments AS (
    SELECT 
        "customer_id",
        DATE_TRUNC('MONTH', TO_TIMESTAMP("payment_date")) AS "payment_month",
        SUM("amount") AS "monthly_total"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT"
    GROUP BY "customer_id", DATE_TRUNC('MONTH', TO_TIMESTAMP("payment_date"))
),
MonthlyChanges AS (
    SELECT 
        "customer_id",
        "payment_month", 
        "monthly_total",
        LAG("monthly_total") OVER (PARTITION BY "customer_id" ORDER BY "payment_month") AS "previous_month_total",
        ABS("monthly_total" - LAG("monthly_total") OVER (PARTITION BY "customer_id" ORDER BY "payment_month")) AS "monthly_change"
    FROM MonthlyPayments
    QUALIFY LAG("monthly_total") OVER (PARTITION BY "customer_id" ORDER BY "payment_month") IS NOT NULL
),
AverageMonthlyChange AS (
    SELECT 
        "customer_id", 
        AVG("monthly_change") AS "avg_monthly_change"
    FROM MonthlyChanges
    GROUP BY "customer_id"
    ORDER BY "avg_monthly_change" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    C."first_name",
    C."last_name",
    A."avg_monthly_change"
FROM AverageMonthlyChange A
JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER" C
ON A."customer_id" = C."customer_id";