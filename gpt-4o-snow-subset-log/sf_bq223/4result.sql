WITH denso_families AS (
    -- Step 1: Identify family IDs of patents assigned to DENSO CORP
    SELECT DISTINCT "family_id" 
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE f.value::VARIANT:"name"::STRING ILIKE '%DENSO CORP%'
), citing_publications AS (
    -- Step 2: Retrieve citing publications and their assignees, excluding DENSO CORP as an assignee
    SELECT DISTINCT 
        t."publication_number" AS "citing_publication", 
        f.value::VARIANT:"name"::STRING AS "citing_assignee_name"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE 
        t."family_id" IN (SELECT "family_id" FROM denso_families)
        AND f.value::VARIANT:"name"::STRING NOT ILIKE '%DENSO CORP%'
), citing_cpcs AS (
    -- Step 3: Extract first CPC code for citing publications
    SELECT DISTINCT 
        t."publication_number" AS "citing_publication", 
        f.value::VARIANT:"code"::STRING AS "cpc_code"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
         LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"first"::BOOLEAN = TRUE
), citing_with_cpcs AS (
    -- Step 4: Join citing publications with their first CPC codes
    SELECT 
        cp."citing_assignee_name", 
        cpc."cpc_code"
    FROM citing_publications cp
    JOIN citing_cpcs cpc
    ON cp."citing_publication" = cpc."citing_publication"
), cpc_titles AS (
    -- Step 5: Map CPC codes to their full titles
    SELECT 
        "symbol" AS "cpc_code", 
        "titleFull" AS "cpc_title"
    FROM PATENTS.PATENTS.CPC_DEFINITION
)
-- Step 6: Aggregate and count citations grouped by citing assignee and CPC title
SELECT 
    cit."citing_assignee_name", 
    cpc_def."cpc_title", 
    COUNT(*) AS "citation_count"
FROM citing_with_cpcs cit
JOIN cpc_titles cpc_def
ON cit."cpc_code" = cpc_def."cpc_code"
GROUP BY cit."citing_assignee_name", cpc_def."cpc_title"
ORDER BY "citation_count" DESC NULLS LAST
LIMIT 20;