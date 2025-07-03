WITH helmeted_collisions AS (
  SELECT 
    COUNT(c."case_id") AS "total_collisions",
    SUM(c."motorcyclist_killed_count") AS "total_fatalities"
  FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
  JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c 
    ON p."case_id" = c."case_id"
  WHERE c."motorcycle_collision" = 1 
    AND p."statewide_vehicle_type" ILIKE '%motorcycle%' 
    AND p."party_safety_equipment_1" ILIKE '%helmet used%'
),
non_helmeted_collisions AS (
  SELECT 
    COUNT(c."case_id") AS "total_collisions",
    SUM(c."motorcyclist_killed_count") AS "total_fatalities"
  FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
  JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c 
    ON p."case_id" = c."case_id"
  WHERE c."motorcycle_collision" = 1 
    AND p."statewide_vehicle_type" ILIKE '%motorcycle%' 
    AND (p."party_safety_equipment_1" NOT ILIKE '%helmet used%' OR p."party_safety_equipment_1" IS NULL)
)
SELECT 
  'Helmeted' AS "Group",
  helmeted_collisions."total_fatalities",
  helmeted_collisions."total_collisions",
  (helmeted_collisions."total_fatalities"::FLOAT / NULLIF(helmeted_collisions."total_collisions", 0)) * 100 AS "fatality_percentage"
FROM helmeted_collisions

UNION ALL

SELECT 
  'Non-Helmeted' AS "Group",
  non_helmeted_collisions."total_fatalities",
  non_helmeted_collisions."total_collisions",
  (non_helmeted_collisions."total_fatalities"::FLOAT / NULLIF(non_helmeted_collisions."total_collisions", 0)) * 100 AS "fatality_percentage"
FROM non_helmeted_collisions;