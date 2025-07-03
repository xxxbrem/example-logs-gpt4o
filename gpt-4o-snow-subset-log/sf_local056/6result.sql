WITH monthly_totals AS (
  SELECT "customer_id",
         SUBSTR("payment_date", 0, 8) AS "year_month",
         SUM("amount") AS "monthly_total"
  FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT"
  GROUP BY "customer_id", SUBSTR("payment_date", 0, 8)
),
month_changes AS (
  SELECT m1."customer_id",
         (m1."monthly_total" - m2."monthly_total") AS "monthly_change"
  FROM monthly_totals m1
  LEFT JOIN monthly_totals m2
  ON m1."customer_id" = m2."customer_id" AND m1."year_month" > m2."year_month"
)
SELECT c."first_name", c."last_name", AVG(ABS(mc."monthly_change")) AS "avg_monthly_change"
FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER" c
JOIN month_changes mc
ON c."customer_id" = mc."customer_id"
GROUP BY c."first_name", c."last_name"
ORDER BY "avg_monthly_change" DESC NULLS LAST
LIMIT 1;