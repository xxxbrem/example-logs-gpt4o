WITH 
-- Calculate total number of motorcycle collisions where helmets were used
helmet_collisions AS (
    SELECT COUNT(DISTINCT c."case_id") AS "helmet_collision_count",
           SUM(c."motorcyclist_killed_count") AS "helmet_fatalities"
    FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
    JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c
    ON p."case_id" = c."case_id"
    WHERE c."motorcycle_collision" = 1 
    AND p."statewide_vehicle_type" ILIKE '%motorcycle%' 
    AND p."party_safety_equipment_1" ILIKE '%helmet%'
),
-- Calculate total number of motorcycle collisions where helmets were not used
no_helmet_collisions AS (
    SELECT COUNT(DISTINCT c."case_id") AS "no_helmet_collision_count",
           SUM(c."motorcyclist_killed_count") AS "no_helmet_fatalities"
    FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
    JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c
    ON p."case_id" = c."case_id"
    WHERE c."motorcycle_collision" = 1 
    AND p."statewide_vehicle_type" ILIKE '%motorcycle%' 
    AND (p."party_safety_equipment_1" NOT ILIKE '%helmet%' OR p."party_safety_equipment_1" IS NULL)
)
-- Calculate the percentages of fatalities
SELECT 
    (h."helmet_fatalities"::FLOAT / NULLIF(h."helmet_collision_count", 0) * 100) AS "helmet_fatality_rate_percentage",
    (nh."no_helmet_fatalities"::FLOAT / NULLIF(nh."no_helmet_collision_count", 0) * 100) AS "no_helmet_fatality_rate_percentage"
FROM helmet_collisions h, no_helmet_collisions nh;