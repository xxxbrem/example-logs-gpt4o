WITH Missed_Rounds AS (
    -- Identify drivers who missed races by comparing rounds in RACES with RESULTS for each year
    SELECT 
        r."year",
        r."round",
        rs."driver_id",
        d."constructor_id",
        LAG(d."constructor_id") OVER (
            PARTITION BY rs."driver_id", r."year" 
            ORDER BY r."round"
        ) AS "prev_constructor_id",
        LEAD(d."constructor_id") OVER (
            PARTITION BY rs."driver_id", r."year" 
            ORDER BY r."round"
        ) AS "next_constructor_id"
    FROM F1.F1.RACES AS r
    LEFT JOIN F1.F1.RESULTS AS rs 
        ON r."race_id" = rs."race_id"
    LEFT JOIN F1.F1.DRIVES AS d 
        ON rs."driver_id" = d."driver_id"
        AND r."year" = d."year"
    WHERE rs."race_id" IS NULL
),
Filtered_Drivers AS (
    -- Filter drivers who missed fewer than 3 races in a year and switched constructors
    SELECT 
        "driver_id", 
        "year",
        MIN("round") AS "first_missed_round",
        MAX("round") AS "last_missed_round"
    FROM Missed_Rounds
    WHERE 
        "prev_constructor_id" IS NOT NULL AND 
        "next_constructor_id" IS NOT NULL AND 
        "prev_constructor_id" != "next_constructor_id"
    GROUP BY "driver_id", "year"
    HAVING COUNT("round") < 3
),
Average_Rounds AS (
    -- Calculate the overall averages for first and last missed rounds
    SELECT 
        AVG("first_missed_round") AS "avg_first_missed_round",
        AVG("last_missed_round") AS "avg_last_missed_round"
    FROM Filtered_Drivers
)
SELECT * 
FROM Average_Rounds;