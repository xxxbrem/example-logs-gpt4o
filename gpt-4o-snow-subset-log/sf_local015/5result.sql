SELECT 
  CASE 
    WHEN p."party_safety_equipment_1" ILIKE '%helmet%' THEN 'Helmet Used'
    ELSE 'No Helmet'
  END AS "helmet_usage",
  SUM(p."party_number_killed")::FLOAT / COUNT(DISTINCT c."case_id") * 100 AS "fatality_percentage"
FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c
ON p."case_id" = c."case_id"
WHERE c."motorcycle_collision" = 1
GROUP BY "helmet_usage"
ORDER BY "helmet_usage";