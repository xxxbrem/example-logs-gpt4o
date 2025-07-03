SELECT a."first_name", a."last_name", COUNT(fa."film_id") AS "appearances"
FROM PAGILA.PAGILA.FILM_ACTOR fa
JOIN PAGILA.PAGILA.ACTOR a 
ON fa."actor_id" = a."actor_id"
WHERE fa."film_id" IN (
    SELECT fc."film_id"
    FROM PAGILA.PAGILA.FILM_CATEGORY fc
    JOIN PAGILA.PAGILA.CATEGORY c 
    ON fc."category_id" = c."category_id"
    JOIN PAGILA.PAGILA.FILM f 
    ON fc."film_id" = f."film_id"
    JOIN PAGILA.PAGILA.LANGUAGE l 
    ON f."language_id" = l."language_id"
    WHERE c."name" ILIKE '%Children%'
    AND f."rating" IN ('G', 'PG')
    AND f."length" <= 120 
    AND f."release_year" BETWEEN '2000' AND '2010'
    AND l."name" ILIKE '%English%'
)
GROUP BY a."actor_id", a."first_name", a."last_name"
ORDER BY "appearances" DESC NULLS LAST
LIMIT 1;