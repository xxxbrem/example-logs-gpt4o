WITH earliest_publications AS (
    -- Fetch each family_id and its earliest publication date in January 2015
    SELECT "family_id", MIN("publication_date") AS "earliest_publication_date"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    WHERE "publication_date" BETWEEN 20150101 AND 20150131
    GROUP BY "family_id"
),
publication_details AS (
    -- Reduce the data by using JOIN with earliest publications
    SELECT ep."family_id", ARRAY_AGG(DISTINCT p."publication_number") AS "publication_numbers", 
           ARRAY_AGG(DISTINCT p."country_code") AS "country_codes"
    FROM earliest_publications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id"
    GROUP BY ep."family_id"
),
cpc_codes AS (
    -- Extract distinct CPC codes for relevant family_ids
    SELECT ep."family_id", ARRAY_AGG(DISTINCT f.value::VARIANT:"code"::STRING) AS "cpc_codes"
    FROM earliest_publications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."cpc") f
    GROUP BY ep."family_id"
),
ipc_codes AS (
    -- Extract distinct IPC codes for relevant family_ids
    SELECT ep."family_id", ARRAY_AGG(DISTINCT f.value::VARIANT:"code"::STRING) AS "ipc_codes"
    FROM earliest_publications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."ipc") f
    GROUP BY ep."family_id"
),
cited_families AS (
    -- Get distinct cited families
    SELECT ep."family_id", ARRAY_AGG(DISTINCT f.value::VARIANT:"publication_number"::STRING) AS "families_cited"
    FROM earliest_publications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."citation") f
    GROUP BY ep."family_id"
),
citing_families AS (
    -- Get distinct citing families
    SELECT ep."family_id", ARRAY_AGG(DISTINCT f.value::VARIANT:"publication_number"::STRING) AS "families_citing"
    FROM earliest_publications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."citation") f
    GROUP BY ep."family_id"
)
-- Combine all results for final output
SELECT 
    ep."family_id",
    ep."earliest_publication_date",
    ARRAY_TO_STRING(pd."publication_numbers", ', ') AS "publication_numbers",
    ARRAY_TO_STRING(pd."country_codes", ', ') AS "country_codes",
    ARRAY_TO_STRING(cc."cpc_codes", ', ') AS "cpc_codes",
    ARRAY_TO_STRING(ic."ipc_codes", ', ') AS "ipc_codes",
    ARRAY_TO_STRING(cf."families_cited", ', ') AS "families_cited",
    ARRAY_TO_STRING(cf2."families_citing", ', ') AS "families_citing"
FROM earliest_publications ep
LEFT JOIN publication_details pd ON ep."family_id" = pd."family_id"
LEFT JOIN cpc_codes cc ON ep."family_id" = cc."family_id"
LEFT JOIN ipc_codes ic ON ep."family_id" = ic."family_id"
LEFT JOIN cited_families cf ON ep."family_id" = cf."family_id"
LEFT JOIN citing_families cf2 ON ep."family_id" = cf2."family_id"
ORDER BY ep."family_id";