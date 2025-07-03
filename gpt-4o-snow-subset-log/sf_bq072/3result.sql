WITH VehicleCodes AS (
    SELECT "Code"
    FROM "DEATH"."DEATH"."ICD10CODE"
    WHERE "Description" ILIKE '%vehicle%'
),
FirearmCodes AS (
    SELECT "Code"
    FROM "DEATH"."DEATH"."ICD10CODE"
    WHERE "Description" ILIKE '%firearm%'
),
VehicleDeaths AS (
    SELECT d."Age", 
           COUNT(*) AS "TotalDeaths", 
           SUM(CASE WHEN d."RaceRecode5" = 2 THEN 1 ELSE 0 END) AS "BlackDeaths"
    FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" e
    JOIN "DEATH"."DEATH"."DEATHRECORDS" d
    ON e."DeathRecordId" = d."Id"
    WHERE e."Icd10Code" IN (SELECT "Code" FROM VehicleCodes)
    AND d."Age" BETWEEN 12 AND 18
    GROUP BY d."Age"
),
FirearmDeaths AS (
    SELECT d."Age", 
           COUNT(*) AS "TotalDeaths", 
           SUM(CASE WHEN d."RaceRecode5" = 2 THEN 1 ELSE 0 END) AS "BlackDeaths"
    FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" e
    JOIN "DEATH"."DEATH"."DEATHRECORDS" d
    ON e."DeathRecordId" = d."Id"
    WHERE e."Icd10Code" IN (SELECT "Code" FROM FirearmCodes)
    AND d."Age" BETWEEN 12 AND 18
    GROUP BY d."Age"
)
SELECT 
    'Vehicle' AS "Category",
    "Age",
    "TotalDeaths",
    "BlackDeaths"
FROM VehicleDeaths
UNION ALL
SELECT 
    'Firearm' AS "Category",
    "Age",
    "TotalDeaths",
    "BlackDeaths"
FROM FirearmDeaths
ORDER BY "Category", "Age";