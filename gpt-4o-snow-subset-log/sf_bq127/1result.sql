WITH EarliestPublicationFamilies AS (
    SELECT 
        "family_id", 
        MIN("publication_date") AS "earliest_publication_date"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    GROUP BY "family_id"
    HAVING MIN("publication_date") BETWEEN 20150101 AND 20150131
),
DistinctPublicationNumbers AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT "publication_number", ',') WITHIN GROUP (ORDER BY "publication_number") AS "publication_numbers"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
),
DistinctCountryCodes AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT "country_code", ',') WITHIN GROUP (ORDER BY "country_code") AS "country_codes"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
),
DistinctCPCCodes AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT f.value::VARIANT:"code"::STRING, ',') WITHIN GROUP (ORDER BY f.value::VARIANT:"code"::STRING) AS "cpc_codes"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS,
         LATERAL FLATTEN(input => "cpc") f
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
),
DistinctIPCCodes AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT f.value::VARIANT:"code"::STRING, ',') WITHIN GROUP (ORDER BY f.value::VARIANT:"code"::STRING) AS "ipc_codes"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS,
         LATERAL FLATTEN(input => "ipc") f
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
),
FamiliesCitedBy AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT f.value::VARIANT:"family_id"::STRING, ',') WITHIN GROUP (ORDER BY f.value::VARIANT:"family_id"::STRING) AS "families_cited_by"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS,
         LATERAL FLATTEN(input => "citation") f
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
),
FamiliesThatCite AS (
    SELECT 
        "family_id", 
        LISTAGG(DISTINCT f.value::VARIANT:"family_id"::STRING, ',') WITHIN GROUP (ORDER BY f.value::VARIANT:"family_id"::STRING) AS "families_that_cite"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS,
         LATERAL FLATTEN(input => "citation") f
    WHERE "family_id" IN (SELECT "family_id" FROM EarliestPublicationFamilies)
    GROUP BY "family_id"
)
SELECT 
    epf."family_id",
    epf."earliest_publication_date",
    dpn."publication_numbers",
    dcc."country_codes",
    dccp."cpc_codes",
    dip."ipc_codes",
    fcb."families_cited_by",
    ftc."families_that_cite"
FROM EarliestPublicationFamilies epf
LEFT JOIN DistinctPublicationNumbers dpn ON epf."family_id" = dpn."family_id"
LEFT JOIN DistinctCountryCodes dcc ON epf."family_id" = dcc."family_id"
LEFT JOIN DistinctCPCCodes dccp ON epf."family_id" = dccp."family_id"
LEFT JOIN DistinctIPCCodes dip ON epf."family_id" = dip."family_id"
LEFT JOIN FamiliesCitedBy fcb ON epf."family_id" = fcb."family_id"
LEFT JOIN FamiliesThatCite ftc ON epf."family_id" = ftc."family_id"
ORDER BY epf."family_id";