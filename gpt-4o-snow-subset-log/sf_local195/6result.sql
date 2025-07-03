WITH TopActorsFilms AS (
    -- Step 1: Select film_ids featuring the top five actors
    SELECT DISTINCT "film_id"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
    WHERE "actor_id" IN (1, 3, 4, 7, 8)
),
TopActorsInventories AS (
    -- Step 2: Match film_ids with inventory_ids
    SELECT DISTINCT "inventory_id"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY"
    WHERE "film_id" IN (SELECT "film_id" FROM TopActorsFilms)
),
TopActorsRentals AS (
    -- Step 3: Find customer_ids who rented these inventory_ids
    SELECT DISTINCT "customer_id"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL"
    WHERE "inventory_id" IN (SELECT "inventory_id" FROM TopActorsInventories)
),
DistinctCustomerCount AS (
    -- Step 4: Count distinct customers who rented films featuring the top actors
    SELECT COUNT(*) AS "top_actors_customers"
    FROM TopActorsRentals
),
TotalCustomerCount AS (
    -- Step 5: Count total distinct customers
    SELECT COUNT(*) AS "total_customers"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER"
)
-- Step 6: Calculate the percentage of customers renting films featuring these actors
SELECT 
    (DAC."top_actors_customers" * 100.0 / TCC."total_customers") AS "percentage_of_customers"
FROM DistinctCustomerCount DAC, TotalCustomerCount TCC;