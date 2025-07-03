WITH DistinctRounds AS (
    SELECT 
        rd."driver_id",
        rs."year",
        COUNT(DISTINCT rs."round") AS "round_count"
    FROM "F1"."F1"."RESULTS" rd
    JOIN "F1"."F1"."RACES" rs
        ON rd."race_id" = rs."race_id"
    WHERE rs."year" BETWEEN 1950 AND 1959
    GROUP BY rd."driver_id", rs."year"
),
ValidDrivers AS (
    SELECT 
        dv."driver_id",
        dv."year",
        dv."constructor_id"
    FROM "F1"."F1"."DRIVES" dv
    WHERE dv."year" BETWEEN 1950 AND 1959
        AND dv."is_first_drive_of_season" = 1
        AND dv."is_final_drive_of_season" = 1
    GROUP BY dv."driver_id", dv."year", dv."constructor_id"
),
FilteredDrivers AS (
    SELECT 
        vd."driver_id",
        vd."year",
        vd."constructor_id"
    FROM ValidDrivers vd
    JOIN DistinctRounds dr
        ON vd."driver_id" = dr."driver_id"
        AND vd."year" = dr."year"
    WHERE dr."round_count" >= 2
)
SELECT 
    d."full_name",
    fd."constructor_id",
    fd."year"
FROM FilteredDrivers fd
JOIN "F1"."F1"."DRIVERS" d
    ON fd."driver_id" = d."driver_id"
LIMIT 20;