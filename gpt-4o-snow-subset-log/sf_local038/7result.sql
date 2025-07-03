SELECT a."first_name", a."last_name"
FROM "PAGILA"."PAGILA"."ACTOR" a
JOIN "PAGILA"."PAGILA"."FILM_ACTOR" fa
  ON a."actor_id" = fa."actor_id"
JOIN (
  SELECT DISTINCT fc."film_id"
  FROM "PAGILA"."PAGILA"."FILM_CATEGORY" fc
  JOIN "PAGILA"."PAGILA"."FILM" f
    ON fc."film_id" = f."film_id"
  WHERE fc."category_id" = (
        SELECT "category_id"
        FROM "PAGILA"."PAGILA"."CATEGORY"
        WHERE "name" ILIKE '%Children%'
      )
    AND f."language_id" = (
        SELECT "language_id"
        FROM "PAGILA"."PAGILA"."LANGUAGE"
        WHERE "name" ILIKE '%English%'
      )
    AND f."rating" IN ('G', 'PG')
    AND f."length" <= 120
    AND f."release_year" BETWEEN '2000' AND '2010'
) filtered_films
  ON fa."film_id" = filtered_films."film_id"
GROUP BY a."actor_id", a."first_name", a."last_name"
ORDER BY COUNT(fa."film_id") DESC NULLS LAST
LIMIT 1;