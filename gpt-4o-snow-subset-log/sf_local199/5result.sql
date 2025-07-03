WITH RENTAL_SUMMARY AS (
    SELECT 
        r."rental_date",
        s."store_id",
        CAST(SUBSTR(r."rental_date", 1, 4) AS INT) AS "year",
        CAST(SUBSTR(r."rental_date", 6, 2) AS INT) AS "month"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."STAFF" s
    ON 
        r."staff_id" = s."staff_id"
),
RENTAL_COUNT AS (
    SELECT 
        "store_id",
        "year",
        "month",
        COUNT(*) AS "total_rentals"
    FROM 
        RENTAL_SUMMARY
    GROUP BY 
        "store_id", "year", "month"
),
MAX_RENTAL AS (
    SELECT 
        "store_id",
        MAX("total_rentals") AS "max_rentals"
    FROM 
        RENTAL_COUNT
    GROUP BY 
        "store_id"
)
SELECT 
    rc."store_id",
    rc."year",
    rc."month",
    rc."total_rentals"
FROM 
    RENTAL_COUNT rc
JOIN 
    MAX_RENTAL mr
ON 
    rc."store_id" = mr."store_id" AND rc."total_rentals" = mr."max_rentals"
ORDER BY 
    rc."store_id", rc."year", rc."month";