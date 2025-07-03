WITH DriverConstructorCombined AS (
    -- Step 1: Get driver points and constructor points for the same race
    SELECT 
        ds."driver_id",
        ds."race_id",
        ds."points" AS "driver_points",
        cs."constructor_id",
        cs."points" AS "constructor_points",
        r."year",
        (ds."points" + cs."points") AS "total_points"
    FROM "F1"."F1"."DRIVER_STANDINGS_EXT" ds
    JOIN "F1"."F1"."CONSTRUCTOR_STANDINGS" cs
        ON ds."race_id" = cs."race_id"
    JOIN "F1"."F1"."RACES" r
        ON ds."race_id" = r."race_id"
),
RankedCombined AS (
    -- Step 2: Rank the constructors based on total combined points in descending order
    SELECT 
        dcc."constructor_id",
        dcc."year",
        dcc."total_points",
        ROW_NUMBER() OVER (PARTITION BY dcc."constructor_id" ORDER BY dcc."total_points" DESC) AS "rank"
    FROM DriverConstructorCombined dcc
),
ConstructorDetails AS (
    -- Step 3: Retrieve constructor references and short names
    SELECT 
        c."constructor_id",
        scn."short_name"
    FROM "F1"."F1"."CONSTRUCTORS" c
    JOIN "F1"."F1"."SHORT_CONSTRUCTOR_NAMES" scn
        ON c."constructor_ref" = scn."constructor_ref"
)
-- Step 4: Filter the top 3 constructors based on their best combined driver and team points
SELECT 
    cd."short_name" AS "constructor_name",
    rc."total_points",
    rc."year"
FROM RankedCombined rc
JOIN ConstructorDetails cd
    ON rc."constructor_id" = cd."constructor_id"
WHERE rc."rank" = 1
ORDER BY rc."total_points" DESC NULLS LAST
LIMIT 3;