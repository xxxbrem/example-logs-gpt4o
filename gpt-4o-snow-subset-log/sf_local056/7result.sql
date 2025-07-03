WITH monthly_changes AS (
    WITH monthly_payments AS (
        SELECT 
            "customer_id", 
            SUBSTR("payment_date", 1, 7) AS "payment_month_year", 
            SUM("amount") AS "total_payment"
        FROM SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT
        GROUP BY "customer_id", "payment_month_year"
    )
    SELECT 
        "customer_id", 
        "total_payment" - LAG("total_payment") OVER (PARTITION BY "customer_id" ORDER BY "payment_month_year") AS "monthly_change"
    FROM monthly_payments
)
SELECT 
    c."first_name", 
    c."last_name", 
    AVG(ABS(mc."monthly_change")) AS "avg_monthly_change"
FROM monthly_changes mc 
JOIN SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c 
    ON mc."customer_id" = c."customer_id"
GROUP BY c."customer_id", c."first_name", c."last_name"
ORDER BY "avg_monthly_change" DESC NULLS LAST 
LIMIT 1;