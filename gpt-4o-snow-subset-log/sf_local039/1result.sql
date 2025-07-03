WITH Filtered_Cities AS (
    SELECT DISTINCT "city_id"
    FROM "PAGILA"."PAGILA"."CITY"
    WHERE "city" ILIKE 'A%' OR "city" ILIKE '%-%'
),
Filtered_Addresses AS (
    SELECT DISTINCT "address_id"
    FROM "PAGILA"."PAGILA"."ADDRESS"
    WHERE "city_id" IN (SELECT "city_id" FROM Filtered_Cities)
),
Filtered_Customers AS (
    SELECT DISTINCT "customer_id"
    FROM "PAGILA"."PAGILA"."CUSTOMER"
    WHERE "address_id" IN (SELECT "address_id" FROM Filtered_Addresses)
),
Filtered_Rentals AS (
    SELECT DISTINCT "rental_id", "inventory_id", "rental_date", "return_date"
    FROM "PAGILA"."PAGILA"."RENTAL"
    WHERE "customer_id" IN (SELECT "customer_id" FROM Filtered_Customers)
    AND "return_date" IS NOT NULL -- Ensure valid timestamps for calculations
    AND "rental_date" IS NOT NULL -- Ensure valid timestamps for calculations
    AND TRY_TO_TIMESTAMP("rental_date") IS NOT NULL -- Ensure valid timestamp conversion
    AND TRY_TO_TIMESTAMP("return_date") IS NOT NULL -- Ensure valid timestamp conversion
),
Filtered_Inventory AS (
    SELECT DISTINCT "inventory_id", "film_id"
    FROM "PAGILA"."PAGILA"."INVENTORY"
    WHERE "inventory_id" IN (SELECT "inventory_id" FROM Filtered_Rentals)
),
Rental_Hours_Per_Film AS (
    SELECT 
        FI."film_id",
        SUM(DATEDIFF('second', TRY_TO_TIMESTAMP(R."rental_date"), TRY_TO_TIMESTAMP(R."return_date")) / 3600.0) AS "total_rental_hours"
    FROM Filtered_Inventory FI
    JOIN Filtered_Rentals R ON FI."inventory_id" = R."inventory_id"
    GROUP BY FI."film_id"
),
Film_Category_Hours AS (
    SELECT 
        FC."category_id",
        SUM(RH."total_rental_hours") AS "total_category_hours"
    FROM "PAGILA"."PAGILA"."FILM_CATEGORY" FC
    JOIN Rental_Hours_Per_Film RH ON FC."film_id" = RH."film_id"
    GROUP BY FC."category_id"
),
Film_Category_With_Name AS (
    SELECT 
        C."name" AS "category_name",
        FCH."total_category_hours"
    FROM Film_Category_Hours FCH
    JOIN "PAGILA"."PAGILA"."CATEGORY" C ON FCH."category_id" = C."category_id"
)
SELECT 
    "category_name",
    "total_category_hours"
FROM Film_Category_With_Name
ORDER BY "total_category_hours" DESC NULLS LAST
LIMIT 1;