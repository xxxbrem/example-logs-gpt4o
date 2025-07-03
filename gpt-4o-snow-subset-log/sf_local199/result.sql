SELECT ranked_rentals."store_id", 
       ranked_rentals."year", 
       ranked_rentals."month", 
       ranked_rentals."total_rentals"
FROM (
    SELECT s."store_id", 
           YEAR(TO_TIMESTAMP(r."rental_date")) AS "year", 
           MONTH(TO_TIMESTAMP(r."rental_date")) AS "month", 
           COUNT(r."rental_id") AS "total_rentals",
           RANK() OVER (PARTITION BY s."store_id" ORDER BY COUNT(r."rental_id") DESC) AS "rank"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."STAFF" s
    ON r."staff_id" = s."staff_id"
    GROUP BY s."store_id", YEAR(TO_TIMESTAMP(r."rental_date")), MONTH(TO_TIMESTAMP(r."rental_date"))
) AS ranked_rentals
WHERE ranked_rentals."rank" = 1
ORDER BY ranked_rentals."store_id", ranked_rentals."year" ASC, ranked_rentals."month" ASC;