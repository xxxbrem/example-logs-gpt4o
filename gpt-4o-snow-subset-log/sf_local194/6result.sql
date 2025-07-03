WITH RevenuePerActor AS (
    SELECT 
        a."actor_id",
        a."first_name",
        a."last_name",
        fa."film_id",
        (SUM(p."amount") / COUNT(DISTINCT fa."actor_id")) AS "average_revenue_per_actor",
        RANK() OVER (PARTITION BY a."actor_id" ORDER BY SUM(p."amount") DESC NULLS LAST) AS "film_rank"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.ACTOR a
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa
        ON a."actor_id" = fa."actor_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i
        ON fa."film_id" = i."film_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r
        ON i."inventory_id" = r."inventory_id"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p
        ON r."rental_id" = p."rental_id"
    GROUP BY a."actor_id", a."first_name", a."last_name", fa."film_id"
),
TopThreeFilmsPerActor AS (
    SELECT 
        "actor_id",
        "first_name",
        "last_name",
        "film_id",
        "average_revenue_per_actor"
    FROM RevenuePerActor
    WHERE "film_rank" <= 3
)
SELECT 
    t."actor_id",
    t."first_name",
    t."last_name",
    t."film_id",
    f."title",
    t."average_revenue_per_actor"
FROM TopThreeFilmsPerActor t
JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM f
    ON t."film_id" = f."film_id"
ORDER BY t."actor_id", t."average_revenue_per_actor" DESC NULLS LAST
LIMIT 20;