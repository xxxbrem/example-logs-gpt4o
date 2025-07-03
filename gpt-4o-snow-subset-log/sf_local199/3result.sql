SELECT 
    "store_id",
    "rental_year",
    "rental_month",
    "monthly_total_rentals"
FROM (
    SELECT 
        inv."store_id", 
        EXTRACT(YEAR FROM CAST(r."rental_date" AS TIMESTAMP)) AS "rental_year", 
        EXTRACT(MONTH FROM CAST(r."rental_date" AS TIMESTAMP)) AS "rental_month", 
        COUNT(r."rental_id") AS "monthly_total_rentals",
        RANK() OVER (
            PARTITION BY inv."store_id" 
            ORDER BY COUNT(r."rental_id") DESC
        ) AS "rank_per_store"
    FROM 
        SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
    JOIN 
        SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY inv
    ON 
        r."inventory_id" = inv."inventory_id"
    GROUP BY 
        inv."store_id", 
        EXTRACT(YEAR FROM CAST(r."rental_date" AS TIMESTAMP)), 
        EXTRACT(MONTH FROM CAST(r."rental_date" AS TIMESTAMP))
) ranked_data
WHERE "rank_per_store" = 1
ORDER BY "store_id", "rental_year", "rental_month";