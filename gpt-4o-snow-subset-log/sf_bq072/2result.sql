WITH VehicleRelatedDeaths AS (
    SELECT dr."Age", dr."Race", COUNT(*) AS "TotalDeaths"
    FROM "DEATH"."DEATH"."DEATHRECORDS" dr
    WHERE dr."Age" BETWEEN 12 AND 18
      AND dr."Id" IN (
          SELECT eac."DeathRecordId"
          FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" eac
          WHERE eac."Icd10Code" IN (
              SELECT "Code" 
              FROM "DEATH"."DEATH"."ICD10CODE" 
              WHERE "Description" ILIKE '%vehicle%'
          )
      )
    GROUP BY dr."Age", dr."Race"
),
FirearmRelatedDeaths AS (
    SELECT dr."Age", dr."Race", COUNT(*) AS "TotalDeaths"
    FROM "DEATH"."DEATH"."DEATHRECORDS" dr
    WHERE dr."Age" BETWEEN 12 AND 18
      AND dr."Id" IN (
          SELECT eac."DeathRecordId"
          FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" eac
          WHERE eac."Icd10Code" IN (
              SELECT "Code" 
              FROM "DEATH"."DEATH"."ICD10CODE" 
              WHERE "Description" ILIKE '%firearm%'
          )
      )
    GROUP BY dr."Age", dr."Race"
),
BlackRaceCodes AS (
    SELECT r."Code"
    FROM "DEATH"."DEATH"."RACE" r
    WHERE r."Description" ILIKE '%Black%'
),
VehicleRelatedSummary AS (
    SELECT 
        vrd."Age",
        SUM(vrd."TotalDeaths") AS "VehicleTotalDeaths",
        SUM(CASE WHEN vrd."Race" IN (SELECT "Code" FROM BlackRaceCodes) THEN vrd."TotalDeaths" ELSE 0 END) AS "VehicleBlackDeaths"
    FROM VehicleRelatedDeaths vrd
    GROUP BY vrd."Age"
),
FirearmRelatedSummary AS (
    SELECT 
        frd."Age",
        SUM(frd."TotalDeaths") AS "FirearmTotalDeaths",
        SUM(CASE WHEN frd."Race" IN (SELECT "Code" FROM BlackRaceCodes) THEN frd."TotalDeaths" ELSE 0 END) AS "FirearmBlackDeaths"
    FROM FirearmRelatedDeaths frd
    GROUP BY frd."Age"
)
SELECT 
    COALESCE(vrs."Age", frs."Age") AS "Age",
    COALESCE(vrs."VehicleTotalDeaths", 0) AS "VehicleTotalDeaths",
    COALESCE(vrs."VehicleBlackDeaths", 0) AS "VehicleBlackDeaths",
    COALESCE(frs."FirearmTotalDeaths", 0) AS "FirearmTotalDeaths",
    COALESCE(frs."FirearmBlackDeaths", 0) AS "FirearmBlackDeaths"
FROM VehicleRelatedSummary vrs
FULL OUTER JOIN FirearmRelatedSummary frs
ON vrs."Age" = frs."Age"
ORDER BY "Age";