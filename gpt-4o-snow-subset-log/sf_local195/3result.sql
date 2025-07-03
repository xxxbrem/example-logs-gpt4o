WITH TopActorsFilms AS (
    SELECT DISTINCT "film_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR
    WHERE "actor_id" IN (1, 3, 4, 7, 8) -- Top 5 actors
),
RelevantInventories AS (
    SELECT DISTINCT "inventory_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY
    WHERE "film_id" IN (SELECT "film_id" FROM TopActorsFilms)
),
CustomersWhoRented AS (
    SELECT DISTINCT "customer_id"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL
    WHERE "inventory_id" IN (SELECT "inventory_id" FROM RelevantInventories)
),
TotalCustomers AS (
    SELECT COUNT(DISTINCT "customer_id") AS "total_customers"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER
),
CustomersWithTopActors AS (
    SELECT COUNT(DISTINCT "customer_id") AS "customers_featuring_top_5_actors"
    FROM CustomersWhoRented
)
SELECT 
    (CAST(cwta."customers_featuring_top_5_actors" AS FLOAT) / tc."total_customers") * 100 AS "percentage_customers"
FROM TotalCustomers tc, CustomersWithTopActors cwta;