SELECT 
    (CAST((
        SELECT COUNT(DISTINCT "RENTAL"."customer_id")
        FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL"
        WHERE "RENTAL"."inventory_id" IN (
            SELECT DISTINCT "INVENTORY"."inventory_id"
            FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY"
            WHERE "INVENTORY"."film_id" IN (
                SELECT "FILM"."film_id"
                FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM"
                JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" 
                    ON "FILM"."film_id" = "FILM_ACTOR"."film_id"
                WHERE "FILM_ACTOR"."actor_id" IN (
                    SELECT "actor_id"
                    FROM (
                        SELECT 
                            "actor_id", 
                            COUNT("film_id") AS "film_count"
                        FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
                        GROUP BY "actor_id"
                        ORDER BY "film_count" DESC NULLS LAST
                        LIMIT 5
                    )
                )
            )
        )
    ) AS FLOAT) / CAST((
        SELECT COUNT(DISTINCT "CUSTOMER"."customer_id")
        FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER"
    ) AS FLOAT)) * 100 AS "percentage_customers";