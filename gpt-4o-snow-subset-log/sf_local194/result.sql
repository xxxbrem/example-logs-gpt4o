WITH FilmRevenue AS (
    SELECT 
        inv."film_id", 
        SUM(pay."amount") AS "film_revenue"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT" pay
    INNER JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" ren
        ON pay."rental_id" = ren."rental_id"
    INNER JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY" inv
        ON ren."inventory_id" = inv."inventory_id"
    GROUP BY 
        inv."film_id"
),
ActorCount AS (
    SELECT 
        "film_id", 
        COUNT("actor_id") AS "actor_count"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
    GROUP BY 
        "film_id"
),
RevenuePerActor AS (
    SELECT 
        rev."film_id", 
        rev."film_revenue", 
        act."actor_count", 
        (rev."film_revenue" / act."actor_count") AS "avg_revenue_per_actor"
    FROM 
        FilmRevenue rev
    INNER JOIN 
        ActorCount act
        ON rev."film_id" = act."film_id"
),
ActorFilmRevenue AS (
    SELECT 
        fa."actor_id", 
        fa."film_id", 
        rev."avg_revenue_per_actor"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" fa
    INNER JOIN 
        RevenuePerActor rev
        ON fa."film_id" = rev."film_id"
),
RankedFilms AS (
    SELECT 
        afr."actor_id", 
        afr."film_id", 
        af."title", 
        afr."avg_revenue_per_actor",
        ROW_NUMBER() OVER (PARTITION BY afr."actor_id" ORDER BY afr."avg_revenue_per_actor" DESC NULLS LAST) AS "rank"
    FROM 
        ActorFilmRevenue afr
    INNER JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM" af
        ON afr."film_id" = af."film_id"
)
SELECT 
    "actor_id", 
    "film_id", 
    "title", 
    "avg_revenue_per_actor"
FROM 
    RankedFilms
WHERE 
    "rank" <= 3
ORDER BY 
    "actor_id", 
    "avg_revenue_per_actor" DESC NULLS LAST;