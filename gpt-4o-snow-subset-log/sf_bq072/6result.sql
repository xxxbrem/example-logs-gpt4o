WITH VehicleRelatedDeaths AS (
  SELECT
    dr."Age",
    dr."Race",
    COUNT(DISTINCT dr."Id") AS "TotalDeaths"
  FROM DEATH.DEATH.DEATHRECORDS dr
  JOIN DEATH.DEATH.ENTITYAXISCONDITIONS ec
    ON dr."Id" = ec."DeathRecordId"
  WHERE dr."Age" BETWEEN 12 AND 18
    AND ec."Icd10Code" IN (
      SELECT DISTINCT "Code"
      FROM DEATH.DEATH.ICD10CODE
      WHERE "Description" ILIKE '%vehicle%'
    )
  GROUP BY dr."Age", dr."Race"
),
FirearmRelatedDeaths AS (
  SELECT
    dr."Age",
    dr."Race",
    COUNT(DISTINCT dr."Id") AS "TotalDeaths"
  FROM DEATH.DEATH.DEATHRECORDS dr
  JOIN DEATH.DEATH.ENTITYAXISCONDITIONS ec
    ON dr."Id" = ec."DeathRecordId"
  WHERE dr."Age" BETWEEN 12 AND 18
    AND ec."Icd10Code" IN (
      SELECT DISTINCT "Code"
      FROM DEATH.DEATH.ICD10CODE
      WHERE "Description" ILIKE '%firearm%'
    )
  GROUP BY dr."Age", dr."Race"
),
BlackRaceCode AS (
  SELECT DISTINCT "Code"
  FROM (
    SELECT "Code", "Description"
    FROM DEATH.DEATH.RACERECODE5
    WHERE "Description" ILIKE '%black%'
    UNION
    SELECT "Code", "Description"
    FROM DEATH.DEATH.RACE
    WHERE "Description" ILIKE '%black%'
  ) AS CombinedRace
),
FinalCounts AS (
  SELECT
    vd."Age",
    'Vehicle' AS "IncidentType",
    SUM(vd."TotalDeaths") AS "TotalDeaths",
    SUM(CASE WHEN vd."Race" IN (SELECT "Code" FROM BlackRaceCode) THEN vd."TotalDeaths" ELSE 0 END) AS "BlackDeaths"
  FROM VehicleRelatedDeaths vd
  GROUP BY vd."Age"
  UNION ALL
  SELECT
    fd."Age",
    'Firearm' AS "IncidentType",
    SUM(fd."TotalDeaths") AS "TotalDeaths",
    SUM(CASE WHEN fd."Race" IN (SELECT "Code" FROM BlackRaceCode) THEN fd."TotalDeaths" ELSE 0 END) AS "BlackDeaths"
  FROM FirearmRelatedDeaths fd
  GROUP BY fd."Age"
)
SELECT
  "Age",
  "IncidentType",
  "TotalDeaths",
  "BlackDeaths"
FROM FinalCounts
ORDER BY "Age", "IncidentType";