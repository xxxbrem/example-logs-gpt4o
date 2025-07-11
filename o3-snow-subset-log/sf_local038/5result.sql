SELECT 
       a."first_name" || ' ' || a."last_name"  AS "actor_full_name"
FROM   PAGILA.PAGILA.ACTOR        AS a
JOIN   PAGILA.PAGILA.FILM_ACTOR   AS fa ON a."actor_id" = fa."actor_id"
JOIN   PAGILA.PAGILA.FILM         AS f  ON f."film_id"   = fa."film_id"
JOIN   PAGILA.PAGILA.LANGUAGE     AS l  ON l."language_id" = f."language_id"
JOIN   PAGILA.PAGILA.FILM_CATEGORY AS fc ON fc."film_id" = f."film_id"
JOIN   PAGILA.PAGILA.CATEGORY     AS c  ON c."category_id" = fc."category_id"
WHERE  l."name"      = 'English'
  AND  c."name"      = 'Children'
  AND  f."rating"    IN ('G','PG')
  AND  f."length"    <= 120
  AND  TO_NUMBER(f."release_year") BETWEEN 2000 AND 2010
GROUP BY a."first_name", a."last_name"
ORDER BY COUNT(*) DESC NULLS LAST
LIMIT 1;