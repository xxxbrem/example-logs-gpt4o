WITH TopFiveActors AS (
    -- Step 1: Retrieve the top five actors with the highest number of film appearances
    SELECT "actor_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR
    GROUP BY "actor_id"
    ORDER BY COUNT("film_id") DESC NULLS LAST
    LIMIT 5
), FilmsByTopActors AS (
    -- Step 2: Retrieve all "film_id"s associated with these top five actors
    SELECT DISTINCT "film_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR
    WHERE "actor_id" IN (SELECT "actor_id" FROM TopFiveActors)
), InventoriesByFilm AS (
    -- Step 3: Retrieve all "inventory_id"s linked to these films
    SELECT DISTINCT "inventory_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY
    WHERE "film_id" IN (SELECT "film_id" FROM FilmsByTopActors)
), CustomersByInventory AS (
    -- Step 4: Retrieve all unique "customer_id"s who rented these inventories
    SELECT DISTINCT "customer_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL
    WHERE "inventory_id" IN (SELECT "inventory_id" FROM InventoriesByFilm)
), TotalUniqueCustomers AS (
    -- Step 5: Calculate the total number of unique customers
    SELECT COUNT(DISTINCT "customer_id") AS "total_customers"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER
), ActorFilmCustomerCount AS (
    -- Step 6: Calculate the number of unique customers who rented films from the top five actors
    SELECT COUNT(DISTINCT "customer_id") AS "customers_with_actors_films"
    FROM CustomersByInventory
)
-- Step 7: Calculate the percentage of customers who rented films featuring top five actors
SELECT 
    (CAST((SELECT "customers_with_actors_films" FROM ActorFilmCustomerCount) AS FLOAT) 
    / CAST((SELECT "total_customers" FROM TotalUniqueCustomers) AS FLOAT)) * 100 AS "actor_film_customer_percentage";