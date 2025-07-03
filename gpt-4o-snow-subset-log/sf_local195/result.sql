SELECT 
  (CAST(COUNT(DISTINCT r."customer_id") AS FLOAT) / 
   (SELECT COUNT(DISTINCT "customer_id") 
    FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER)) * 100 AS "percentage_of_customers_with_top_actors"
FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r 
WHERE r."inventory_id" IN (
  SELECT DISTINCT i."inventory_id" 
  FROM SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i 
  JOIN SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa 
  ON i."film_id" = fa."film_id" 
  WHERE fa."actor_id" IN (1, 3, 4, 7, 8)
);