SELECT a."first_name", a."last_name", COUNT(fa."film_id") AS "film_count"
FROM "PAGILA"."PAGILA"."ACTOR" a
JOIN "PAGILA"."PAGILA"."FILM_ACTOR" fa ON a."actor_id" = fa."actor_id"
JOIN (
    SELECT DISTINCT f."film_id"
    FROM "PAGILA"."PAGILA"."FILM" f
    JOIN "PAGILA"."PAGILA"."FILM_CATEGORY" fc ON f."film_id" = fc."film_id"
    JOIN "PAGILA"."PAGILA"."CATEGORY" c ON fc."category_id" = c."category_id"
    JOIN "PAGILA"."PAGILA"."LANGUAGE" l ON f."language_id" = l."language_id"
    WHERE c."name" = 'Children' 
      AND l."name" = 'English' 
      AND (f."rating" = 'G' OR f."rating" = 'PG') 
      AND f."length" <= 120 
      AND f."release_year" BETWEEN '2000' AND '2010'
) filtered_film ON fa."film_id" = filtered_film."film_id"
GROUP BY a."first_name", a."last_name"
ORDER BY "film_count" DESC NULLS LAST
LIMIT 1;