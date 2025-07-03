SELECT a."first_name", a."last_name"
FROM PAGILA.PAGILA.ACTOR a
JOIN (
  SELECT fa."actor_id", COUNT(fa."film_id") AS "film_count"
  FROM PAGILA.PAGILA.FILM_ACTOR fa
  JOIN (
    SELECT f."film_id"
    FROM PAGILA.PAGILA.FILM f
    JOIN PAGILA.PAGILA.LANGUAGE l
    ON f."language_id" = l."language_id"
    JOIN PAGILA.PAGILA.FILM_CATEGORY fc
    ON f."film_id" = fc."film_id"
    JOIN PAGILA.PAGILA.CATEGORY c
    ON fc."category_id" = c."category_id"
    WHERE l."name" = 'English'
      AND f."rating" IN ('G', 'PG')
      AND f."length" <= 120
      AND f."release_year" BETWEEN '2000' AND '2010'
      AND c."name" = 'Family'
  ) filtered_films
  ON fa."film_id" = filtered_films."film_id"
  GROUP BY fa."actor_id"
  ORDER BY "film_count" DESC NULLS LAST
  LIMIT 1
) top_actor
ON a."actor_id" = top_actor."actor_id"
LIMIT 1;