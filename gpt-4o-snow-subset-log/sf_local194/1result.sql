WITH RankedFilms AS (
    SELECT 
        FA."actor_id",
        A."first_name",
        A."last_name",
        F."title",
        (SUM(P."amount") / COUNT(DISTINCT FA."actor_id")) AS "average_revenue_per_actor",
        ROW_NUMBER() OVER (PARTITION BY FA."actor_id" ORDER BY SUM(P."amount") DESC NULLS LAST) AS "rank"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR FA
    INNER JOIN SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY I ON FA."film_id" = I."film_id"
    INNER JOIN SQLITE_SAKILA.SQLITE_SAKILA.RENTAL R ON I."inventory_id" = R."inventory_id"
    INNER JOIN SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT P ON R."rental_id" = P."rental_id"
    INNER JOIN SQLITE_SAKILA.SQLITE_SAKILA.ACTOR A ON FA."actor_id" = A."actor_id"
    INNER JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM F ON FA."film_id" = F."film_id"
    GROUP BY FA."actor_id", A."first_name", A."last_name", F."title"
)
SELECT 
    "actor_id", 
    "first_name", 
    "last_name", 
    "title", 
    "average_revenue_per_actor"
FROM RankedFilms
WHERE "rank" <= 3
ORDER BY "actor_id", "rank";