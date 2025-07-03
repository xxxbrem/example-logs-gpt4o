SELECT 
    AVG(d."first_round") AS "overall_avg_first_round_missed", 
    AVG(d."last_round") AS "overall_avg_last_round_missed"
FROM F1.F1.DRIVES d
JOIN (
    SELECT 
        r1."driver_id", 
        r1."race_id" AS "pre_miss_race_id", 
        r1."constructor_id" AS "pre_miss_constr",
        r2."race_id" AS "post_miss_race_id", 
        r2."constructor_id" AS "post_miss_constr"
    FROM F1.F1.RESULTS r1
    JOIN F1.F1.RESULTS r2 
        ON r1."driver_id" = r2."driver_id" 
        AND (r1."race_id" + 1) = r2."race_id"
    WHERE r1."constructor_id" != r2."constructor_id"
) t ON d."driver_id" = t."driver_id"
WHERE ((d."last_round" - d."first_round") - 1 < 3);