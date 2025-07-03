WITH Utility_Patents_2010 AS (
    SELECT 
        "publication_number",
        "application_number",
        "family_id",
        "filing_date",
        "grant_date"
    FROM 
        "PATENTS"."PATENTS"."PUBLICATIONS"
    WHERE 
        "grant_date" >= 20100101 
        AND "grant_date" <= 20101231
        AND "application_kind" = 'U'
),
Forward_Citations AS (
    SELECT 
        p."publication_number", 
        p."application_number", 
        f.value::VARIANT:"application_number"::STRING AS "citing_application_number",
        TO_DATE(p."filing_date"::STRING, 'YYYYMMDD') AS "filing_date"
    FROM 
        "PATENTS"."PATENTS"."PUBLICATIONS" p, 
        LATERAL FLATTEN(input => p."citation") f
    WHERE 
        p."application_kind" = 'U'
),
Citations_Filtered AS (
    SELECT
        u."publication_number",
        u."application_number",
        COUNT(DISTINCT f."citing_application_number") AS "citation_count"
    FROM 
        Utility_Patents_2010 u
    LEFT JOIN 
        Forward_Citations f
    ON 
        u."publication_number" = f."publication_number"
        AND f."citing_application_number" IS NOT NULL
        AND TO_DATE(u."filing_date"::STRING, 'YYYYMMDD') <= f."filing_date"
        AND f."filing_date" <= DATEADD(YEAR, 10, TO_DATE(u."filing_date"::STRING, 'YYYYMMDD'))
    GROUP BY 
        u."publication_number", 
        u."application_number"
)
SELECT 
    COUNT(*)
FROM 
    Citations_Filtered
WHERE 
    "citation_count" = 1;