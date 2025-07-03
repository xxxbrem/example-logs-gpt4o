WITH Earliest_Publications AS (
    SELECT 
        "family_id", 
        MIN("publication_date") AS "earliest_publication_date"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    GROUP BY 
        "family_id"
    HAVING 
        MIN("publication_date") BETWEEN 20150101 AND 20150131
),
Distinct_Publications AS (
    SELECT 
        ep."family_id", 
        p."publication_number", 
        p."country_code"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    INNER JOIN 
        Earliest_Publications ep ON p."family_id" = ep."family_id"
),
Distinct_CPC AS (
    SELECT 
        t."family_id", 
        f.value::VARIANT:"code"::STRING AS "cpc_code"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS t,
        LATERAL FLATTEN(INPUT => t."cpc") f
    WHERE 
        t."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
),
Distinct_IPC AS (
    SELECT 
        t."family_id", 
        f.value::VARIANT:"code"::STRING AS "ipc_code"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS t,
        LATERAL FLATTEN(INPUT => t."ipc") f
    WHERE 
        t."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
),
Cited_Families AS (
    SELECT 
        t."family_id", 
        f.value::VARIANT:"publication_number"::STRING AS "cited_family"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS t,
        LATERAL FLATTEN(INPUT => t."citation") f
    WHERE 
        t."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
),
Citing_Families AS (
    SELECT 
        f1."family_id" AS "citing_family", 
        f2."family_id" AS "cited_family"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS f1,
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS f2,
        LATERAL FLATTEN(INPUT => f2."citation") fc
    WHERE 
        f2."family_id" IN (SELECT "family_id" FROM Earliest_Publications)
        AND fc.value::VARIANT:"publication_number"::STRING = f1."publication_number"
)
SELECT 
    ep."family_id", 
    ep."earliest_publication_date", 
    LISTAGG(DISTINCT dp."publication_number", ', ') AS "publication_numbers", 
    LISTAGG(DISTINCT dp."country_code", ', ') AS "country_codes", 
    LISTAGG(DISTINCT dpc."cpc_code", ', ') AS "cpc_codes", 
    LISTAGG(DISTINCT dip."ipc_code", ', ') AS "ipc_codes", 
    LISTAGG(DISTINCT cf."cited_family", ', ') AS "cited_families", 
    LISTAGG(DISTINCT cf_ct."citing_family", ', ') AS "citing_families"
FROM 
    Earliest_Publications ep
LEFT JOIN 
    Distinct_Publications dp 
    ON ep."family_id" = dp."family_id"
LEFT JOIN 
    Distinct_CPC dpc 
    ON ep."family_id" = dpc."family_id"
LEFT JOIN 
    Distinct_IPC dip 
    ON ep."family_id" = dip."family_id"
LEFT JOIN 
    Cited_Families cf 
    ON ep."family_id" = cf."family_id"
LEFT JOIN 
    Citing_Families cf_ct 
    ON ep."family_id" = cf_ct."cited_family"
GROUP BY 
    ep."family_id", ep."earliest_publication_date"
ORDER BY 
    ep."family_id";