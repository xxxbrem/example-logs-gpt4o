WITH January2015Publications AS (
    -- Retrieve publication families with earliest publication in January 2015
    SELECT DISTINCT "family_id", MIN("publication_date") AS "earliest_publication_date"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS"
    WHERE "publication_date" BETWEEN 20150101 AND 20150131
    GROUP BY "family_id"
),
PublicationDetails AS (
    -- Consolidate details for the publications belonging to the above families
    SELECT p."family_id",
           p."publication_date",
           p."publication_number",
           p."country_code",
           cpc_codes.value:"code"::STRING AS "cpc_code",
           ipc_codes.value:"code"::STRING AS "ipc_code"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" p,
         TABLE(FLATTEN(input => p."cpc")) cpc_codes,
         TABLE(FLATTEN(input => p."ipc")) ipc_codes
    WHERE p."family_id" IN (SELECT "family_id" FROM January2015Publications)
),
CitedFamilies AS (
    -- Extract cited families related to these publication families
    SELECT DISTINCT p."family_id" AS "source_family_id", 
           c.value:"family_id"::STRING AS "cited_family_id"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" p,
         TABLE(FLATTEN(input => p."citation")) c
    WHERE p."family_id" IN (SELECT "family_id" FROM January2015Publications)
),
CitingFamilies AS (
    -- Identify families citing these publication families
    SELECT DISTINCT cited_by.value:"family_id"::STRING AS "citing_family_id", 
                    ae."publication_number"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" ae,
         TABLE(FLATTEN(input => ae."cited_by")) cited_by
    WHERE cited_by.value:"publication_number"::STRING IN (
        SELECT "publication_number" FROM PublicationDetails
    )
)
SELECT jp."family_id",
       jp."earliest_publication_date",
       LISTAGG(DISTINCT pd."publication_number", ',') WITHIN GROUP (ORDER BY pd."publication_number") AS "publication_numbers",
       LISTAGG(DISTINCT pd."country_code", ',') WITHIN GROUP (ORDER BY pd."country_code") AS "country_codes",
       LISTAGG(DISTINCT pd."cpc_code", ',') WITHIN GROUP (ORDER BY pd."cpc_code") AS "cpc_codes",
       LISTAGG(DISTINCT pd."ipc_code", ',') WITHIN GROUP (ORDER BY pd."ipc_code") AS "ipc_codes",
       LISTAGG(DISTINCT cf."cited_family_id", ',') WITHIN GROUP (ORDER BY cf."cited_family_id") AS "cited_families",
       LISTAGG(DISTINCT ci."citing_family_id", ',') WITHIN GROUP (ORDER BY ci."citing_family_id") AS "citing_families"
FROM January2015Publications jp
LEFT JOIN PublicationDetails pd ON jp."family_id" = pd."family_id"
LEFT JOIN CitedFamilies cf ON jp."family_id" = cf."source_family_id"
LEFT JOIN CitingFamilies ci ON ci."publication_number" = pd."publication_number"
GROUP BY jp."family_id", jp."earliest_publication_date"
ORDER BY jp."family_id";