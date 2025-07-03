WITH TeamSwitchesWithMissedRaces AS (
    SELECT 
        d1."driver_id", 
        d1."year", 
        d1."constructor_id" AS "before_constructor_id", 
        d1."last_round" AS "last_round_before",
        d2."constructor_id" AS "after_constructor_id", 
        d2."first_round" AS "first_round_after",
        d2."first_round" - d1."last_round" - 1 AS "missed_races_count"
    FROM "F1"."F1"."DRIVES" d1
    JOIN "F1"."F1"."DRIVES" d2 
        ON d1."driver_id" = d2."driver_id" 
       AND d1."year" = d2."year" 
       AND d1."last_round" < d2."first_round"
    WHERE d1."constructor_id" <> d2."constructor_id"
),
FilteredSwitches AS (
    SELECT 
        "driver_id", 
        "year", 
        "last_round_before", 
        "first_round_after"
    FROM TeamSwitchesWithMissedRaces
    WHERE "missed_races_count" < 3
),
AverageMissedRounds AS (
    SELECT 
        AVG("last_round_before" + 1) AS "average_first_round_missed",
        AVG("first_round_after" - 1) AS "average_last_round_missed"
    FROM FilteredSwitches
)
SELECT 
    "average_first_round_missed", 
    "average_last_round_missed"
FROM AverageMissedRounds;