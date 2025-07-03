WITH VehicleFirearmICD10Codes AS (
    SELECT DISTINCT "Code", 'Vehicle' AS "Category"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%vehicle%'
    UNION ALL
    SELECT DISTINCT "Code", 'Firearm' AS "Category"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%firearm%'
),
DeathsWithCodes AS (
    SELECT DISTINCT eac."DeathRecordId", vfc."Category"
    FROM DEATH.DEATH.ENTITYAXISCONDITIONS eac
    JOIN VehicleFirearmICD10Codes vfc
    ON eac."Icd10Code" = vfc."Code"
),
BlackRaceCodes AS (
    SELECT DISTINCT "Code"
    FROM DEATH.DEATH.RACERECODE3
    WHERE "Description" ILIKE '%black%'
    UNION ALL
    SELECT DISTINCT "Code"
    FROM DEATH.DEATH.RACERECODE5
    WHERE "Description" ILIKE '%black%'
),
DeathsSummary AS (
    SELECT
        dr."Age",
        dwc."Category",
        COUNT(dr."Id") AS "TotalDeaths",
        COUNT(CASE WHEN dr."RaceRecode3" IN (SELECT "Code" FROM BlackRaceCodes)
                    OR dr."RaceRecode5" IN (SELECT "Code" FROM BlackRaceCodes)
                   THEN 1 END) AS "BlackDeaths"
    FROM DEATH.DEATH.DEATHRECORDS dr
    JOIN DeathsWithCodes dwc
    ON dr."Id" = dwc."DeathRecordId"
    WHERE dr."Age" BETWEEN 12 AND 18
    GROUP BY dr."Age", dwc."Category"
)
SELECT 
    "Age",
    "Category",
    "TotalDeaths",
    "BlackDeaths"
FROM DeathsSummary
ORDER BY "Age", "Category";