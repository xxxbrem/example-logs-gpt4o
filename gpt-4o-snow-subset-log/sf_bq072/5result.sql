WITH Vehicle_ICD10_Codes AS (
    SELECT "Code"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%vehicle%'
),
Firearm_ICD10_Codes AS (
    SELECT "Code"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%firearm%'
),
Vehicle_Deaths AS (
    SELECT 
        d."Age",
        COUNT(*) AS "TotalDeaths",
        SUM(CASE WHEN r."Description" ILIKE '%black%' THEN 1 ELSE 0 END) AS "BlackDeaths"
    FROM DEATH.DEATH.DEATHRECORDS d
    JOIN DEATH.DEATH.ENTITYAXISCONDITIONS e 
        ON d."Id" = e."DeathRecordId"
    LEFT JOIN DEATH.DEATH.RACERECODE5 r 
        ON d."RaceRecode5" = r."Code"
    WHERE d."Age" BETWEEN 12 AND 18
    AND e."Icd10Code" IN (SELECT "Code" FROM Vehicle_ICD10_Codes)
    GROUP BY d."Age"
),
Firearm_Deaths AS (
    SELECT 
        d."Age",
        COUNT(*) AS "TotalDeaths",
        SUM(CASE WHEN r."Description" ILIKE '%black%' THEN 1 ELSE 0 END) AS "BlackDeaths"
    FROM DEATH.DEATH.DEATHRECORDS d
    JOIN DEATH.DEATH.ENTITYAXISCONDITIONS e 
        ON d."Id" = e."DeathRecordId"
    LEFT JOIN DEATH.DEATH.RACERECODE5 r 
        ON d."RaceRecode5" = r."Code"
    WHERE d."Age" BETWEEN 12 AND 18
    AND e."Icd10Code" IN (SELECT "Code" FROM Firearm_ICD10_Codes)
    GROUP BY d."Age"
)
SELECT 
    COALESCE(v."Age", f."Age") AS "Age",
    v."TotalDeaths" AS "Vehicle_TotalDeaths",
    v."BlackDeaths" AS "Vehicle_BlackDeaths",
    f."TotalDeaths" AS "Firearm_TotalDeaths",
    f."BlackDeaths" AS "Firearm_BlackDeaths"
FROM Vehicle_Deaths v
FULL OUTER JOIN Firearm_Deaths f
ON v."Age" = f."Age"
ORDER BY "Age";