SELECT s."store_id", 
       TO_CHAR(TO_TIMESTAMP(r."rental_date"), 'YYYY') AS "year", 
       TO_CHAR(TO_TIMESTAMP(r."rental_date"), 'MM') AS "month", 
       COUNT(r."rental_id") AS "total_rentals"
FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
JOIN SQLITE_SAKILA.SQLITE_SAKILA.STAFF s 
ON r."staff_id" = s."staff_id"
GROUP BY s."store_id", "year", "month"
QUALIFY RANK() OVER (PARTITION BY s."store_id" ORDER BY COUNT(r."rental_id") DESC) = 1
ORDER BY s."store_id"
LIMIT 20;