SELECT 
    i."store_id", 
    CAST(SUBSTR(r."rental_date", 1, 4) AS INTEGER) AS "year", 
    CAST(SUBSTR(r."rental_date", 6, 2) AS INTEGER) AS "month", 
    COUNT(r."rental_id") AS "total_rentals"
FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
JOIN SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i ON r."inventory_id" = i."inventory_id"
GROUP BY i."store_id", "year", "month"
QUALIFY RANK() OVER (PARTITION BY i."store_id" ORDER BY COUNT(r."rental_id") DESC NULLS LAST) = 1
ORDER BY i."store_id", "year", "month";