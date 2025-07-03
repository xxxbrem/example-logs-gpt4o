SELECT 
    S."store_id", 
    EXTRACT(YEAR FROM TO_TIMESTAMP(R."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')) AS "year", 
    EXTRACT(MONTH FROM TO_TIMESTAMP(R."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')) AS "month", 
    COUNT(*) AS "total_rentals"
FROM 
    "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" R
JOIN 
    "SQLITE_SAKILA"."SQLITE_SAKILA"."STAFF" ST ON R."staff_id" = ST."staff_id"
JOIN 
    "SQLITE_SAKILA"."SQLITE_SAKILA"."STORE" S ON ST."store_id" = S."store_id"
GROUP BY 
    S."store_id", 
    EXTRACT(YEAR FROM TO_TIMESTAMP(R."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')), 
    EXTRACT(MONTH FROM TO_TIMESTAMP(R."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF'))
QUALIFY 
    ROW_NUMBER() OVER (PARTITION BY S."store_id" ORDER BY COUNT(*) DESC NULLS LAST) = 1
ORDER BY 
    S."store_id", "year", "month";