WITH fatalities_with_helmet AS (
    SELECT SUM(c."motorcyclist_killed_count") AS "total_fatalities_with_helmet"
    FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON c."case_id" = p."case_id"
    WHERE c."motorcycle_collision" = 1 AND p."party_safety_equipment_1" ILIKE '%helmet%'
),
fatalities_without_helmet AS (
    SELECT SUM(c."motorcyclist_killed_count") AS "total_fatalities_without_helmet"
    FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON c."case_id" = p."case_id"
    WHERE c."motorcycle_collision" = 1 AND (p."party_safety_equipment_1" NOT ILIKE '%helmet%'
    OR p."party_safety_equipment_1" = '')
),
collisions_with_helmet AS (
    SELECT COUNT(DISTINCT c."case_id") AS "total_collisions_with_helmet"
    FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON c."case_id" = p."case_id"
    WHERE c."motorcycle_collision" = 1 AND p."party_safety_equipment_1" ILIKE '%helmet%'
),
collisions_without_helmet AS (
    SELECT COUNT(DISTINCT c."case_id") AS "total_collisions_without_helmet"
    FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON c."case_id" = p."case_id"
    WHERE c."motorcycle_collision" = 1 AND (p."party_safety_equipment_1" NOT ILIKE '%helmet%'
    OR p."party_safety_equipment_1" = '')
)
SELECT 
    (fw."total_fatalities_with_helmet" / cw."total_collisions_with_helmet") * 100 AS "fatality_percentage_with_helmet",
    (fwout."total_fatalities_without_helmet" / cwout."total_collisions_without_helmet") * 100 AS "fatality_percentage_without_helmet"
FROM fatalities_with_helmet fw, fatalities_without_helmet fwout, collisions_with_helmet cw, collisions_without_helmet cwout;