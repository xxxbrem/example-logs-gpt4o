SELECT t."filing_date" AS "Year", 
       f.value::VARIANT:"name"::STRING AS "Assignee", 
       COUNT(*) AS "Application_Count"
FROM PATENTS.PATENTS.PUBLICATIONS t, 
     LATERAL FLATTEN(input => t."assignee_harmonized") f
WHERE f.value::VARIANT:"name" = (
    SELECT f2.value::VARIANT:"name"::STRING AS "Top_Assignee"
    FROM PATENTS.PATENTS.PUBLICATIONS t2, 
         LATERAL FLATTEN(input => t2."assignee_harmonized") f2
    WHERE t2."family_id" IN (
        SELECT DISTINCT t3."family_id"
        FROM PATENTS.PATENTS.PUBLICATIONS t3, 
             LATERAL FLATTEN(input => t3."cpc") f3
        WHERE f3.value::VARIANT:"code" ILIKE 'A61%'
    )
    GROUP BY f2.value::VARIANT:"name"
    ORDER BY COUNT(*) DESC NULLS LAST
    LIMIT 1
)
AND t."family_id" IN (
    SELECT DISTINCT t4."family_id"
    FROM PATENTS.PATENTS.PUBLICATIONS t4, 
         LATERAL FLATTEN(input => t4."cpc") f4
    WHERE f4.value::VARIANT:"code" ILIKE 'A61%'
)
GROUP BY t."filing_date", f.value::VARIANT:"name"
ORDER BY "Application_Count" DESC NULLS LAST;