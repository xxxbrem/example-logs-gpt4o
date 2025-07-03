WITH EarliestPublications AS (
    SELECT 
        "family_id",
        MIN("publication_date") AS earliest_pub_date
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    GROUP BY "family_id"
    HAVING earliest_pub_date >= 20150101 AND earliest_pub_date < 20150201
),
PublicationDetails AS (
    SELECT 
        ep."family_id",
        ep.earliest_pub_date,
        p."publication_number",
        p."country_code"
    FROM EarliestPublications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id" AND ep.earliest_pub_date = p."publication_date"
),
IPC_Codes AS (
    SELECT DISTINCT
        ep."family_id",
        f.value::VARIANT:"code"::STRING AS "ipc_code"
    FROM EarliestPublications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."ipc") f
),
CPC_Codes AS (
    SELECT DISTINCT
        ep."family_id",
        f.value::VARIANT:"code"::STRING AS "cpc_code"
    FROM EarliestPublications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."cpc") f
),
CitedByFamilies AS (
    SELECT DISTINCT
        ep."family_id" AS "cited_family_id",
        cited_by.value::VARIANT:"family_id"::STRING AS "citing_family_id"
    FROM EarliestPublications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."citation") cited_by
    WHERE cited_by.value::VARIANT:"family_id" IS NOT NULL
),
CitingFamilies AS (
    SELECT DISTINCT
        ep."family_id" AS "citing_family_id",
        cited_by.value::VARIANT:"family_id"::STRING AS "cited_family_id"
    FROM EarliestPublications ep
    JOIN PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON ep."family_id" = p."family_id",
    LATERAL FLATTEN(input => p."citation") cited_by
    WHERE cited_by.value::VARIANT:"family_id" IS NOT NULL
)
SELECT 
    ed."family_id",
    ed.earliest_pub_date,
    LISTAGG(DISTINCT ed."publication_number", ',') WITHIN GROUP (ORDER BY ed."publication_number") AS publication_numbers,
    LISTAGG(DISTINCT ed."country_code", ',') WITHIN GROUP (ORDER BY ed."country_code") AS country_codes,
    LISTAGG(DISTINCT ipc."ipc_code", ',') WITHIN GROUP (ORDER BY ipc."ipc_code") AS ipc_codes,
    LISTAGG(DISTINCT cpc."cpc_code", ',') WITHIN GROUP (ORDER BY cpc."cpc_code") AS cpc_codes,
    LISTAGG(DISTINCT cbf."citing_family_id", ',') WITHIN GROUP (ORDER BY cbf."citing_family_id") AS cited_by_families,
    LISTAGG(DISTINCT cif."cited_family_id", ',') WITHIN GROUP (ORDER BY cif."cited_family_id") AS citing_families
FROM PublicationDetails ed
LEFT JOIN IPC_Codes ipc ON ed."family_id" = ipc."family_id"
LEFT JOIN CPC_Codes cpc ON ed."family_id" = cpc."family_id"
LEFT JOIN CitedByFamilies cbf ON ed."family_id" = cbf."cited_family_id"
LEFT JOIN CitingFamilies cif ON ed."family_id" = cif."citing_family_id"
GROUP BY ed."family_id", ed.earliest_pub_date
ORDER BY ed.earliest_pub_date, ed."family_id";