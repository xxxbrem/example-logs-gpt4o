WITH helmet_usage AS (
    SELECT 
        p."case_id", 
        c."motorcyclist_killed_count", 
        CASE 
            WHEN LOWER(p."party_safety_equipment_1") LIKE '%helmet used%' THEN 'helmet_used'
            WHEN LOWER(p."party_safety_equipment_1") LIKE '%helmet not used%' THEN 'helmet_not_used'
            ELSE 'unknown'
        END AS "helmet_status"
    FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES p
    JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS c
    ON p."case_id" = c."case_id"
    WHERE c."motorcycle_collision" = 1
),
grouped_data AS (
    SELECT 
        "helmet_status",
        COUNT(DISTINCT "case_id") AS "total_motorcycle_collisions",
        SUM("motorcyclist_killed_count") AS "total_motorcyclist_fatalities"
    FROM helmet_usage
    WHERE "helmet_status" IN ('helmet_used', 'helmet_not_used')
    GROUP BY "helmet_status"
),
percentages AS (
    SELECT 
        "helmet_status",
        (SUM("total_motorcyclist_fatalities")::FLOAT / SUM("total_motorcycle_collisions")::FLOAT) * 100 AS "fatality_rate_percentage"
    FROM grouped_data
    GROUP BY "helmet_status"
)
SELECT 
    "helmet_status",
    "fatality_rate_percentage"
FROM percentages;