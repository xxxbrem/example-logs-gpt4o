WITH FILM_REVENUE AS (
    SELECT 
        "i"."film_id", 
        SUM("p"."amount") AS "total_revenue", 
        COUNT(DISTINCT "fa"."actor_id") AS "actor_count"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT" "p"
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" "r" 
        ON "p"."rental_id" = "r"."rental_id"
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY" "i" 
        ON "r"."inventory_id" = "i"."inventory_id"
    JOIN 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" "fa"
        ON "fa"."film_id" = "i"."film_id"
    GROUP BY 
        "i"."film_id"
),
AVERAGE_REVENUE_PER_ACTOR AS (
    SELECT 
        "fa"."actor_id",
        "fr"."film_id",
        ("fr"."total_revenue" / "fr"."actor_count") AS "average_revenue_per_actor"
    FROM 
        "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" "fa"
    JOIN 
        FILM_REVENUE "fr"
        ON "fa"."film_id" = "fr"."film_id"
),
TOP_3_FILMS_PER_ACTOR AS (
    SELECT 
        "actor_id", 
        "film_id", 
        "average_revenue_per_actor",
        ROW_NUMBER() OVER (PARTITION BY "actor_id" ORDER BY "average_revenue_per_actor" DESC NULLS LAST) AS "rank"
    FROM 
        AVERAGE_REVENUE_PER_ACTOR
),
TOP_FILMS_WITH_AGGREGATE AS (
    SELECT 
        "actor_id",
        AVG("average_revenue_per_actor") AS "avg_revenue_top_3"
    FROM 
        TOP_3_FILMS_PER_ACTOR
    WHERE 
        "rank" <= 3
    GROUP BY 
        "actor_id"
)
SELECT 
    "t3"."actor_id",
    "a"."first_name",
    "a"."last_name",
    "t3"."avg_revenue_top_3"
FROM 
    TOP_FILMS_WITH_AGGREGATE "t3"
JOIN 
    "SQLITE_SAKILA"."SQLITE_SAKILA"."ACTOR" "a"
    ON "t3"."actor_id" = "a"."actor_id"
ORDER BY 
    "t3"."avg_revenue_top_3" DESC NULLS LAST
LIMIT 20;