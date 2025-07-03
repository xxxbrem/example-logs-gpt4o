WITH helmet_usage AS (
    SELECT 
        p."case_id",
        CASE 
            WHEN p."party_safety_equipment_1" ILIKE '%helmet%' 
                 OR p."party_safety_equipment_2" ILIKE '%helmet%' THEN 'helmet_used'
            ELSE 'no_helmet'
        END AS "helmet_status"
    FROM 
        "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    JOIN 
        "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    ON 
        p."case_id" = c."case_id"
    WHERE 
        c."motorcycle_collision" = 1
),
collision_fatalities AS (
    SELECT 
        h."helmet_status",
        COUNT(DISTINCT h."case_id") AS "collision_count",
        SUM(c."motorcyclist_killed_count") AS "fatality_count"
    FROM 
        helmet_usage h
    JOIN 
        "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    ON 
        h."case_id" = c."case_id"
    GROUP BY 
        h."helmet_status"
)
SELECT 
    "helmet_status",
    "fatality_count",
    "collision_count",
    ("fatality_count" * 100.0 / NULLIF("collision_count", 0)) AS "fatality_rate_percent"
FROM 
    collision_fatalities;