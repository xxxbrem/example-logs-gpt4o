SELECT 
    outer_query."store_id",
    outer_query."year",
    outer_query."month",
    outer_query."total_rentals"
FROM (
    SELECT 
        s."store_id",
        SUBSTR(r."rental_date", 1, 4) AS "year",
        SUBSTR(r."rental_date", 6, 2) AS "month",
        COUNT(*) AS "total_rentals",
        RANK() OVER (PARTITION BY s."store_id" ORDER BY COUNT(*) DESC NULLS LAST) AS "rank"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."STAFF" s
        ON r."staff_id" = s."staff_id"
    GROUP BY s."store_id", "year", "month"
) outer_query
WHERE outer_query."rank" = 1
ORDER BY outer_query."store_id";