SELECT 
    d."Age",
    COUNT(*) AS "Total_Deaths_Vehicle",
    SUM(CASE 
            WHEN d."Race" IN (
                SELECT "Code"
                FROM DEATH.DEATH.RACERECODE5
                WHERE "Description" ILIKE '%black%'
            ) THEN 1 
            ELSE 0 
        END) AS "Black_Deaths_Vehicle"
FROM DEATH.DEATH.DEATHRECORDS d
JOIN DEATH.DEATH.ENTITYAXISCONDITIONS e
  ON d."Id" = e."DeathRecordId"
WHERE d."Age" BETWEEN 12 AND 18
  AND e."Icd10Code" IN (
    SELECT "Code"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%vehicle%'
  )
GROUP BY d."Age"

UNION ALL

SELECT 
    d."Age",
    COUNT(*) AS "Total_Deaths_Firearm",
    SUM(CASE 
            WHEN d."Race" IN (
                SELECT "Code"
                FROM DEATH.DEATH.RACERECODE5
                WHERE "Description" ILIKE '%black%'
            ) THEN 1 
            ELSE 0 
        END) AS "Black_Deaths_Firearm"
FROM DEATH.DEATH.DEATHRECORDS d
JOIN DEATH.DEATH.ENTITYAXISCONDITIONS e
  ON d."Id" = e."DeathRecordId"
WHERE d."Age" BETWEEN 12 AND 18
  AND e."Icd10Code" IN (
    SELECT "Code"
    FROM DEATH.DEATH.ICD10CODE
    WHERE "Description" ILIKE '%firearm%'
  )
GROUP BY d."Age"
ORDER BY "Age";