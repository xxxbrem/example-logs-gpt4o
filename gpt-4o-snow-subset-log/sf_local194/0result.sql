WITH FilmRevenue AS (
    SELECT 
        i."film_id",
        SUM(p."amount") AS "total_revenue"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT" p
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
    ON 
        p."rental_id" = r."rental_id"
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY" i
    ON 
        r."inventory_id" = i."inventory_id"
    GROUP BY 
        i."film_id"
),
FilmActorCount AS (
    SELECT 
        "film_id",
        COUNT("actor_id") AS "actor_count"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
    GROUP BY 
        "film_id"
),
FilmAverageRevenue AS (
    SELECT 
        fr."film_id",
        fr."total_revenue",
        fa."actor_count",
        (fr."total_revenue" / fa."actor_count") AS "avg_revenue_per_actor"
    FROM 
        FilmRevenue fr
    JOIN 
        FilmActorCount fa
    ON 
        fr."film_id" = fa."film_id"
),
RankedFilms AS (
    SELECT 
        fa."actor_id",
        fa."film_id",
        f."title",
        far."avg_revenue_per_actor",
        ROW_NUMBER() OVER (
            PARTITION BY fa."actor_id" 
            ORDER BY far."avg_revenue_per_actor" DESC NULLS LAST
        ) AS "rank"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" fa
    JOIN 
        FilmAverageRevenue far
    ON 
        fa."film_id" = far."film_id"
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM" f
    ON 
        fa."film_id" = f."film_id"
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
    "rank";