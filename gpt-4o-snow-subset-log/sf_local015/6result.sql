WITH 
-- Step 1: Filter motorcycle collision cases with helmet information
helmet_usage AS (
    SELECT 
        p."case_id", 
        p."party_number", 
        c."motorcyclist_killed_count",
        p."party_safety_equipment_1",
        CASE 
            WHEN p."party_safety_equipment_1" ILIKE '%helmet%' THEN 'helmet_used'
            WHEN p."party_safety_equipment_1" ILIKE '%none%' OR p."party_safety_equipment_1" = '' THEN 'helmet_not_used'
            ELSE 'unknown'
        END AS helmet_status
    FROM 
        "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS" c
    JOIN 
        "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
    ON 
        c."case_id" = p."case_id"
    WHERE 
        c."motorcycle_collision" = 1 
        AND p."statewide_vehicle_type" ILIKE '%motorcycle%'
),
-- Step 2: Aggregate fatalities by helmet usage
fatalities_by_helmet_status AS (
    SELECT 
        helmet_status, 
        COUNT(DISTINCT "case_id") AS total_collisions, 
        SUM("motorcyclist_killed_count") AS total_fatalities
    FROM 
        helmet_usage
    WHERE 
        helmet_status IN ('helmet_used', 'helmet_not_used') 
    GROUP BY 
        helmet_status
),
-- Step 3: Calculate the fatality rate for each helmet status
fatality_rate AS (
    SELECT 
        helmet_status,
        total_fatalities,
        total_collisions,
        (total_fatalities * 100.0 / total_collisions) AS fatality_rate
    FROM 
        fatalities_by_helmet_status
)
-- Step 4: Retrieve the result
SELECT 
    helmet_status,
    total_fatalities,
    total_collisions,
    fatality_rate
FROM 
    fatality_rate;