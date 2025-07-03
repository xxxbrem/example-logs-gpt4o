WITH driver_race_participation AS (
    -- Step 1: Map which races each driver participated in for a given year
    SELECT 
        r."year", 
        r."round", 
        rs."driver_id", 
        rs."constructor_id"
    FROM 
        "F1"."F1"."RACES" r
    LEFT JOIN 
        "F1"."F1"."RESULTS" rs
    ON 
        r."race_id" = rs."race_id"
),
driver_all_rounds AS (
    -- Step 2: Identify all rounds for each driver in a given year and find gaps (missed races)
    SELECT 
        p1."year", 
        p1."driver_id", 
        p1."constructor_id" AS "constructor_before", 
        p1."round" AS "last_round_before_gap",
        p2."constructor_id" AS "constructor_after",
        p2."round" AS "first_round_after_gap",
        (p2."round" - p1."round" - 1) AS "missed_count"
    FROM 
        driver_race_participation p1
    INNER JOIN 
        driver_race_participation p2
    ON 
        p1."driver_id" = p2."driver_id" 
        AND p1."year" = p2."year"
        AND p2."round" > p1."round"
    WHERE 
        p2."round" - p1."round" > 1
),
filtered_missed_races AS (
    -- Step 3: Filter only drivers who missed fewer than 3 races and switched constructors
    SELECT 
        "year", 
        "driver_id", 
        "last_round_before_gap" AS "first_missed_round",
        "first_round_after_gap" AS "last_missed_round",
        "missed_count"
    FROM 
        driver_all_rounds
    WHERE 
        "missed_count" < 3
        AND "constructor_before" <> "constructor_after"
),
averages AS (
    -- Step 4: Calculate the average of the first and last missed rounds
    SELECT 
        AVG("first_missed_round") AS "avg_first_missed_round",
        AVG("last_missed_round") AS "avg_last_missed_round"
    FROM 
        filtered_missed_races
)
-- Step 5: Return the overall averages
SELECT 
    "avg_first_missed_round", 
    "avg_last_missed_round"
FROM 
    averages;