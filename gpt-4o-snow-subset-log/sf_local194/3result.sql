WITH ActorFilmRevenue AS (
    SELECT 
        fa."actor_id", 
        i."film_id", 
        f."title", 
        SUM(p."amount") / COUNT(DISTINCT fa."actor_id") AS "average_revenue_per_actor"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i
        ON fa."film_id" = i."film_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM f
        ON i."film_id" = f."film_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
        ON r."inventory_id" = i."inventory_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p
        ON r."rental_id" = p."rental_id"
    GROUP BY fa."actor_id", i."film_id", f."title"
),
RankedActorFilmRevenue AS (
    SELECT 
        "actor_id", 
        "film_id", 
        "title", 
        "average_revenue_per_actor", 
        ROW_NUMBER() OVER (PARTITION BY "actor_id" ORDER BY "average_revenue_per_actor" DESC NULLS LAST) AS "rank"
    FROM ActorFilmRevenue
)
SELECT 
    "actor_id", 
    "film_id", 
    "title", 
    "average_revenue_per_actor"
FROM RankedActorFilmRevenue
WHERE "rank" <= 3
ORDER BY "actor_id", "rank";