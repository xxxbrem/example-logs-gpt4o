WITH Earliest_Publications AS (
    SELECT 
        p."family_id",
        MIN(p."publication_date") AS "earliest_pub_date"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    WHERE 
        p."publication_date" BETWEEN 20150101 AND 20150131
    GROUP BY 
        p."family_id"
),
Distinct_Publication_Numbers AS (
    SELECT 
        p."family_id", 
        LISTAGG(DISTINCT p."publication_number", ', ') WITHIN GROUP (ORDER BY p."publication_number") AS "publication_numbers"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    WHERE 
        p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
    GROUP BY 
        p."family_id"
),
Distinct_Country_Codes AS (
    SELECT 
        p."family_id", 
        LISTAGG(DISTINCT p."country_code", ', ') WITHIN GROUP (ORDER BY p."country_code") AS "country_codes"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    WHERE 
        p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
    GROUP BY 
        p."family_id"
),
Distinct_CPC_Codes AS (
    SELECT 
        p."family_id", 
        LISTAGG(DISTINCT f.value::VARIANT:"code"::STRING, ', ') WITHIN GROUP (ORDER BY f.value::VARIANT:"code"::STRING) AS "cpc_codes"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p,
        LATERAL FLATTEN(input => p."cpc") f
    WHERE 
        p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
    GROUP BY 
        p."family_id"
),
Distinct_IPC_Codes AS (
    SELECT 
        p."family_id",
        LISTAGG(DISTINCT f.value::VARIANT:"code"::STRING, ', ') WITHIN GROUP (ORDER BY f.value::VARIANT:"code"::STRING) AS "ipc_codes"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p,
        LATERAL FLATTEN(input => p."ipc") f
    WHERE 
        p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
    GROUP BY 
        p."family_id"
),
Families_Cited_By AS (
    SELECT 
        p."family_id",
        LISTAGG(DISTINCT c.value::VARIANT:"family_id"::STRING, ', ') WITHIN GROUP (ORDER BY c.value::VARIANT:"family_id"::STRING) AS "cited_by_families"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p,
        LATERAL FLATTEN(input => p."citation") c
    WHERE 
        p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
        AND c.value::VARIANT:"family_id" IS NOT NULL
    GROUP BY 
        p."family_id"
),
Families_Citing AS (
    SELECT 
        c.value::VARIANT:"family_id"::STRING AS "family_id",
        LISTAGG(DISTINCT p."family_id", ', ') WITHIN GROUP (ORDER BY p."family_id") AS "citing_families"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p,
        LATERAL FLATTEN(input => p."citation") c
    WHERE 
        c.value::VARIANT:"family_id" IS NOT NULL
        AND p."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
    GROUP BY 
        c.value::VARIANT:"family_id"::STRING
)
SELECT 
    e."family_id",
    e."earliest_pub_date",
    COALESCE(dpn."publication_numbers", '') AS "publication_numbers",
    COALESCE(dcc."country_codes", '') AS "country_codes",
    COALESCE(dccodes."cpc_codes", '') AS "cpc_codes",
    COALESCE(dicodes."ipc_codes", '') AS "ipc_codes",
    COALESCE(fcb."cited_by_families", '') AS "cited_by_families",
    COALESCE(fc."citing_families", '') AS "citing_families"
FROM 
    Earliest_Publications e
LEFT JOIN 
    Distinct_Publication_Numbers dpn ON e."family_id" = dpn."family_id"
LEFT JOIN 
    Distinct_Country_Codes dcc ON e."family_id" = dcc."family_id"
LEFT JOIN 
    Distinct_CPC_Codes dccodes ON e."family_id" = dccodes."family_id"
LEFT JOIN 
    Distinct_IPC_Codes dicodes ON e."family_id" = dicodes."family_id"
LEFT JOIN 
    Families_Cited_By fcb ON e."family_id" = fcb."family_id"
LEFT JOIN 
    Families_Citing fc ON e."family_id" = fc."family_id"
ORDER BY 
    e."family_id";