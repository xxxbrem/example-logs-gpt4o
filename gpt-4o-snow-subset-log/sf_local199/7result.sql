WITH RentalCounts AS (
  SELECT 
    i."store_id", 
    SUBSTR(r."rental_date", 1, 4) AS "year",
    SUBSTR(r."rental_date", 6, 2) AS "month",
    COUNT(r."rental_id") AS "total_rentals"
  FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
  JOIN SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i 
  ON r."inventory_id" = i."inventory_id"
  GROUP BY i."store_id", SUBSTR(r."rental_date", 1, 4), SUBSTR(r."rental_date", 6, 2)
)
SELECT rc1."store_id", rc1."year", rc1."month", rc1."total_rentals"
FROM RentalCounts rc1
JOIN (
  SELECT "store_id", MAX("total_rentals") AS "max_rentals"
  FROM RentalCounts
  GROUP BY "store_id"
) rc2
ON rc1."store_id" = rc2."store_id" AND rc1."total_rentals" = rc2."max_rentals"
ORDER BY rc1."store_id", rc1."year", rc1."month";