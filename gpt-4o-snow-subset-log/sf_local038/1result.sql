SELECT CONCAT(a."first_name", ' ', a."last_name") AS full_name
FROM PAGILA.PAGILA.ACTOR a
JOIN PAGILA.PAGILA.FILM_ACTOR fa ON a."actor_id" = fa."actor_id"
JOIN PAGILA.PAGILA.FILM_CATEGORY fc ON fa."film_id" = fc."film_id"
JOIN PAGILA.PAGILA.FILM f ON fa."film_id" = f."film_id"
WHERE f."release_year" BETWEEN '2000' AND '2010'
  AND f."length" <= 120
  AND (f."rating" = 'G' OR f."rating" = 'PG')
  AND f."language_id" = 1
  AND fc."category_id" = 7
GROUP BY a."actor_id", a."first_name", a."last_name"
ORDER BY COUNT(fa."film_id") DESC NULLS LAST
LIMIT 1;