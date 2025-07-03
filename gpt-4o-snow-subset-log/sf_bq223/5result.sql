WITH DENSO_PATENTS AS (
    -- Retrieve family IDs and publications for patents assigned to DENSO CORP
    SELECT DISTINCT t."family_id", t."publication_number"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."assignee_harmonized") f
    WHERE f.value::VARIANT:"name"::STRING ILIKE '%DENSO CORP%'
),
CITING_PUBLICATIONS AS (
    -- Retrieve publications citing DENSO CORP patents and exclude citations by DENSO CORP itself
    SELECT DISTINCT p."publication_number" AS "citing_publication",
           f.value::VARIANT:"name"::STRING AS "citing_assignee",
           p."family_id" AS "citing_family_id"
    FROM PATENTS.PATENTS.PUBLICATIONS p, 
    LATERAL FLATTEN(input => p."assignee_harmonized") f,
    LATERAL FLATTEN(input => p."citation") c
    WHERE c.value::VARIANT:"publication_number"::STRING IN (
        SELECT DISTINCT "publication_number" 
        FROM DENSO_PATENTS
    )
    AND f.value::VARIANT:"name"::STRING NOT ILIKE '%DENSO CORP%'
),
CITING_CPC AS (
    -- Link citing publications to their first CPC code
    SELECT DISTINCT p."publication_number" AS "citing_publication",
           SUBSTR(f.value::VARIANT:"code"::STRING, 0, 4) AS "cpc_code"
    FROM PATENTS.PATENTS.PUBLICATIONS p, 
    LATERAL FLATTEN(input => p."cpc") f
    WHERE f.value::VARIANT:"code"::STRING IS NOT NULL
),
CPC_TITLES AS (
    -- Retrieve full titles of CPC codes
    SELECT DISTINCT cp."symbol" AS "cpc_code", cp."titleFull" AS "cpc_title"
    FROM PATENTS.PATENTS.CPC_DEFINITION cp
),
CITED_INFO AS (
    -- Combine citing assignees, CPC subclass titles, and link titles to CPC codes
    SELECT cp."citing_assignee", 
           cpc."cpc_code", 
           title."cpc_title"
    FROM CITING_PUBLICATIONS cp
    JOIN CITING_CPC cpc ON cp."citing_publication" = cpc."citing_publication"
    JOIN CPC_TITLES title ON cpc."cpc_code" = title."cpc_code"
)
-- Final aggregation to count citations grouped by citing assignee and CPC subclass title
SELECT "citing_assignee", 
       "cpc_title", 
       COUNT(*) AS "citation_count"
FROM CITED_INFO
GROUP BY "citing_assignee", "cpc_title"
ORDER BY "citation_count" DESC NULLS LAST;