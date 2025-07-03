SELECT a."first_name", a."last_name", COUNT(fa."film_id") AS "film_count"
FROM PAGILA.PAGILA."ACTOR" a
JOIN PAGILA.PAGILA."FILM_ACTOR" fa
    ON a."actor_id" = fa."actor_id"
WHERE fa."film_id" IN (
    SELECT DISTINCT f."film_id"
    FROM PAGILA.PAGILA."FILM" f
    JOIN PAGILA.PAGILA."LANGUAGE" l
        ON f."language_id" = l."language_id"
    JOIN PAGILA.PAGILA."FILM_CATEGORY" fc
        ON f."film_id" = fc."film_id"
    JOIN PAGILA.PAGILA."CATEGORY" c
        ON fc."category_id" = c."category_id"
    WHERE l."name" ILIKE '%English%'
      AND f."rating" IN ('G', 'PG')
      AND f."length" <= 120
      AND f."release_year" BETWEEN '2000' AND '2010'
      AND c."name" ILIKE '%Children%'
)
GROUP BY a."actor_id", a."first_name", a."last_name"
ORDER BY "film_count" DESC NULLS LAST
LIMIT 1;