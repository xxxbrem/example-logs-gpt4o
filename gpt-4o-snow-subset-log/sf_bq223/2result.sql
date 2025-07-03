WITH DENSO_PATENTS AS (
    -- Step 1: Identify patents assigned to DENSO CORP
    SELECT DISTINCT 
        t1."family_id"
    FROM PATENTS.PATENTS.PUBLICATIONS t1, 
         LATERAL FLATTEN(input => t1."assignee_harmonized") assignee_f
    WHERE assignee_f.value::VARIANT:"name"::STRING ILIKE '%DENSO%'
),
CITING_PATENTS AS (
    -- Step 2: Get citing patents excluding DENSO CORP itself
    SELECT DISTINCT
        t2."publication_number",
        t2."family_id",
        cpc_u.value::VARIANT:"code"::STRING AS "first_cpc_code",
        assignee_f.value::VARIANT:"name"::STRING AS "citing_assignee"
    FROM PATENTS.PATENTS.PUBLICATIONS t2,
         LATERAL FLATTEN(input => t2."cpc") cpc_u,
         LATERAL FLATTEN(input => t2."assignee_harmonized") assignee_f
    WHERE cpc_u.value::VARIANT:"first"::BOOLEAN = TRUE
      AND assignee_f.value::VARIANT:"name"::STRING NOT ILIKE '%DENSO%'
      AND t2."family_id" IN (SELECT "family_id" FROM DENSO_PATENTS)
),
CPC_CLASS_TITLES AS (
    -- Step 3: Fetch CPC titles for the first CPC codes
    SELECT DISTINCT
        t3."symbol" AS "cpc_code",
        t3."titleFull" AS "cpc_title"
    FROM PATENTS.PATENTS.CPC_DEFINITION t3
)
-- Step 4: Combine data to fetch citing assignees, CPC subclass titles, and citation count
SELECT
    cp."citing_assignee",
    ct."cpc_title",
    COUNT(DISTINCT cp."publication_number") AS "citation_count"
FROM CITING_PATENTS cp
LEFT JOIN CPC_CLASS_TITLES ct
    ON cp."first_cpc_code" = ct."cpc_code"
GROUP BY 
    cp."citing_assignee",
    ct."cpc_title"
HAVING ct."cpc_title" IS NOT NULL
ORDER BY 
    "citation_count" DESC NULLS LAST;