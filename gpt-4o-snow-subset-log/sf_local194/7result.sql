WITH RankedFilms AS (
    SELECT 
        fa."actor_id",
        f."title",
        SUM(p."amount") AS "total_revenue",
        COUNT(DISTINCT fa."actor_id") AS "actor_count",
        RANK() OVER (PARTITION BY fa."actor_id" ORDER BY SUM(p."amount") DESC) AS "rank"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM f ON fa."film_id" = f."film_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p ON fa."film_id" = p."rental_id"
    GROUP BY fa."actor_id", f."title"
)
SELECT 
    r."actor_id",
    r."title",
    r."total_revenue" / r."actor_count" AS "avg_revenue_per_actor"
FROM RankedFilms r
WHERE r."rank" <= 3
ORDER BY r."actor_id", r."rank"