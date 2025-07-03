SELECT c."first_name", c."last_name", t3."avg_monthly_change"
FROM (
    SELECT "customer_id", 
           AVG(ABS("monthly_change")) AS "avg_monthly_change"
    FROM (
        SELECT "customer_id", 
               ("total_monthly_payment" - LAG("total_monthly_payment") OVER (PARTITION BY "customer_id" ORDER BY "year", "month")) AS "monthly_change"
        FROM (
            SELECT "customer_id", 
                   CAST(SUBSTR("payment_date", 1, 4) AS INTEGER) AS "year",
                   CAST(SUBSTR("payment_date", 6, 2) AS INTEGER) AS "month",
                   SUM("amount") AS "total_monthly_payment"
            FROM SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT
            GROUP BY "customer_id", "year", "month"
        ) t
    ) t2
    GROUP BY "customer_id"
    ORDER BY "avg_monthly_change" DESC NULLS LAST
    LIMIT 1
) t3
JOIN SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c
ON t3."customer_id" = c."customer_id";