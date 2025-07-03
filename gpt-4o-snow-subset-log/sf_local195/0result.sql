SELECT 
    (COUNT(DISTINCT r."customer_id") * 100.0 / COUNT(DISTINCT c."customer_id")) AS "Percentage_Customers_Top_Actors"
FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c
LEFT JOIN SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
ON c."customer_id" = r."customer_id"
AND r."inventory_id" IN (
    SELECT DISTINCT "inventory_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY
    WHERE "film_id" IN (
        SELECT DISTINCT "film_id"
        FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR
        WHERE "actor_id" IN (
            SELECT "actor_id"
            FROM SQLITE_SAKILA.SQLITE_SAKILA.ACTOR
            ORDER BY "actor_id"
            LIMIT 5
        )
    )
);