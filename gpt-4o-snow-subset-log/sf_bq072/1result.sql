WITH VehicleDeaths AS (
    SELECT 
        dr."Age", 
        dr."RaceRecode3",
        rc3."Description" AS "RaceDescription"
    FROM DEATH.DEATH.ENTITYAXISCONDITIONS ec
    JOIN DEATH.DEATH.DEATHRECORDS dr 
        ON ec."DeathRecordId" = dr."Id"
    JOIN DEATH.DEATH.ICD10CODE ic 
        ON ec."Icd10Code" = ic."Code"
    JOIN DEATH.DEATH.RACERECODE3 rc3 
        ON dr."RaceRecode3" = rc3."Code"
    WHERE dr."Age" BETWEEN 12 AND 18 
      AND dr."AgeType" = 1 
      AND ic."Description" ILIKE '%vehicle%'
),
FirearmDeaths AS (
    SELECT 
        dr."Age", 
        dr."RaceRecode3",
        rc3."Description" AS "RaceDescription"
    FROM DEATH.DEATH.ENTITYAXISCONDITIONS ec
    JOIN DEATH.DEATH.DEATHRECORDS dr 
        ON ec."DeathRecordId" = dr."Id"
    JOIN DEATH.DEATH.ICD10CODE ic 
        ON ec."Icd10Code" = ic."Code"
    JOIN DEATH.DEATH.RACERECODE3 rc3 
        ON dr."RaceRecode3" = rc3."Code"
    WHERE dr."Age" BETWEEN 12 AND 18 
      AND dr."AgeType" = 1 
      AND ic."Description" ILIKE '%firearm%'
)
SELECT 
    "Age",
    'Vehicle' AS "IncidentType",
    COUNT(*) AS "TotalDeaths",
    SUM(CASE WHEN "RaceDescription" ILIKE '%black%' THEN 1 ELSE 0 END) AS "BlackDeaths"
FROM VehicleDeaths
GROUP BY "Age"
UNION ALL
SELECT 
    "Age",
    'Firearm' AS "IncidentType",
    COUNT(*) AS "TotalDeaths",
    SUM(CASE WHEN "RaceDescription" ILIKE '%black%' THEN 1 ELSE 0 END) AS "BlackDeaths"
FROM FirearmDeaths
GROUP BY "Age"
ORDER BY "Age", "IncidentType";