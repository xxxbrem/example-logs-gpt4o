WITH HelmetUsage AS (
    SELECT 
        c."case_id",
        c."motorcyclist_killed_count",
        CASE 
            WHEN p."party_safety_equipment_1" ILIKE '%helmet%' THEN 'with_helmet'
            WHEN p."party_safety_equipment_1" ILIKE '%not%' THEN 'without_helmet'
            ELSE NULL
        END AS helmet_usage
    FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON c."case_id" = p."case_id"
    WHERE c."motorcycle_collision" = 1
),
AggregatedData AS (
    SELECT 
        helmet_usage,
        COUNT(DISTINCT "case_id") AS total_collisions,
        SUM("motorcyclist_killed_count") AS total_fatalities
    FROM HelmetUsage
    WHERE helmet_usage IN ('with_helmet', 'without_helmet')
    GROUP BY helmet_usage
)
SELECT 
    helmet_usage,
    (total_fatalities::FLOAT / total_collisions) * 100 AS fatality_rate_percentage
FROM AggregatedData;