WITH MonthlyPayments AS (
    SELECT 
        p."customer_id",
        c."first_name",
        c."last_name",
        TO_CHAR(TO_DATE(p."payment_date"), 'YYYY-MM') AS "payment_month",
        SUM(p."amount") AS "monthly_total"
    FROM 
        SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p
    JOIN 
        SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c 
    ON 
        p."customer_id" = c."customer_id"
    GROUP BY 
        p."customer_id", c."first_name", c."last_name", TO_CHAR(TO_DATE(p."payment_date"), 'YYYY-MM')
),
MonthlyChanges AS (
    SELECT 
        t1."customer_id",
        t1."first_name",
        t1."last_name",
        (t1."monthly_total" - t2."monthly_total") AS "monthly_change"
    FROM 
        MonthlyPayments t1
    LEFT JOIN 
        MonthlyPayments t2
    ON 
        t1."customer_id" = t2."customer_id" 
        AND DATEADD(MONTH, 1, TO_DATE(t2."payment_month" || '-01')) = TO_DATE(t1."payment_month" || '-01')
),
AverageMonthlyChange AS (
    SELECT 
        "customer_id",
        "first_name",
        "last_name",
        AVG(ABS("monthly_change")) AS "avg_monthly_change"
    FROM 
        MonthlyChanges
    WHERE 
        "monthly_change" IS NOT NULL
    GROUP BY 
        "customer_id", "first_name", "last_name"
)
SELECT 
    "customer_id",
    "first_name",
    "last_name",
    "avg_monthly_change"
FROM 
    AverageMonthlyChange
ORDER BY 
    "avg_monthly_change" DESC NULLS LAST
LIMIT 1;