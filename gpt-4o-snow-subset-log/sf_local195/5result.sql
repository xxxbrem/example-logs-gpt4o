SELECT 
    (SELECT COUNT(DISTINCT r."customer_id")
     FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
     WHERE r."inventory_id" IN (
         SELECT DISTINCT i."inventory_id"
         FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY" i
         WHERE i."film_id" IN (
             SELECT DISTINCT fa."film_id"
             FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" fa
             WHERE fa."actor_id" IN (
                 SELECT "actor_id"
                 FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
                 GROUP BY "actor_id"
                 ORDER BY COUNT(DISTINCT "film_id") DESC NULLS LAST
                 LIMIT 5
             )
         )
     )
    ) * 100.0 / 
    (SELECT COUNT(DISTINCT "customer_id")
     FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER"
    ) AS "percentage_of_customers";