SELECT a."first_name", a."last_name"
FROM PAGILA.PAGILA.ACTOR a
WHERE a."actor_id" = (
    SELECT "actor_id"
    FROM (
        SELECT "actor_id", COUNT("film_id") AS "film_count"
        FROM PAGILA.PAGILA.FILM_ACTOR fa
        WHERE fa."film_id" IN (
            SELECT fc."film_id"
            FROM PAGILA.PAGILA.FILM_CATEGORY fc
            JOIN PAGILA.PAGILA.FILM f 
              ON f."film_id" = fc."film_id"
            JOIN PAGILA.PAGILA.CATEGORY c 
              ON fc."category_id" = c."category_id"
            WHERE f."language_id" = (
                SELECT "language_id"
                FROM PAGILA.PAGILA.LANGUAGE
                WHERE "name" ILIKE '%English%'
            )
              AND f."rating" IN ('G', 'PG')
              AND f."length" <= 120
              AND f."release_year" BETWEEN '2000' AND '2010'
              AND c."name" ILIKE '%Children%'
        )
        GROUP BY "actor_id"
        ORDER BY "film_count" DESC NULLS LAST
        LIMIT 1
    ) subquery
);