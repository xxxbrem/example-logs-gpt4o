SELECT 
    d."Age", 
    COUNT(*) AS "TotalDeaths", 
    SUM(CASE WHEN d."RaceRecode5" = 2 THEN 1 ELSE 0 END) AS "BlackDeaths",
    SUM(CASE WHEN e."Icd10Code" IN (
        SELECT DISTINCT "Code"
        FROM "DEATH"."DEATH"."ICD10CODE"
        WHERE "Description" ILIKE '%vehicle%'
    ) THEN 1 ELSE 0 END) AS "VehicleDeaths",
    SUM(CASE WHEN d."RaceRecode5" = 2 AND e."Icd10Code" IN (
        SELECT DISTINCT "Code"
        FROM "DEATH"."DEATH"."ICD10CODE"
        WHERE "Description" ILIKE '%vehicle%'
    ) THEN 1 ELSE 0 END) AS "BlackVehicleDeaths",
    SUM(CASE WHEN e."Icd10Code" IN (
        SELECT DISTINCT "Code"
        FROM "DEATH"."DEATH"."ICD10CODE"
        WHERE "Description" ILIKE '%firearm%'
    ) THEN 1 ELSE 0 END) AS "FirearmDeaths",
    SUM(CASE WHEN d."RaceRecode5" = 2 AND e."Icd10Code" IN (
        SELECT DISTINCT "Code"
        FROM "DEATH"."DEATH"."ICD10CODE"
        WHERE "Description" ILIKE '%firearm%'
    ) THEN 1 ELSE 0 END) AS "BlackFirearmDeaths"
FROM 
    "DEATH"."DEATH"."DEATHRECORDS" d
JOIN 
    "DEATH"."DEATH"."ENTITYAXISCONDITIONS" e
    ON d."Id" = e."DeathRecordId"
WHERE 
    d."Age" BETWEEN 12 AND 18
GROUP BY 
    d."Age"
ORDER BY 
    d."Age";