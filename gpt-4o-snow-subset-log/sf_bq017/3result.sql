WITH denmark_boundary AS (
    SELECT t."geometry"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES t, 
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value::VARIANT:"key"::STRING = 'wikidata' 
      AND f.value::VARIANT:"value"::STRING = 'Q35'
    LIMIT 1
),
highways_in_denmark AS (
    SELECT 
        highway."geometry",
        highway_type.value::VARIANT:"value"::STRING AS "highway_type"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES highway,
         LATERAL FLATTEN(input => highway."all_tags") highway_type,
         denmark_boundary db
    WHERE highway_type.value::VARIANT:"key"::STRING = 'highway'
      AND ST_INTERSECTS(ST_GEOGFROMWKB(highway."geometry"), ST_GEOGFROMWKB(db."geometry"))
),
highways_with_lengths AS (
    SELECT 
        "highway_type",
        ST_LENGTH(ST_GEOGFROMWKB("geometry")) AS "length_in_meters"
    FROM highways_in_denmark
),
aggregated_highways AS (
    SELECT 
        "highway_type",
        SUM("length_in_meters") AS "total_length"
    FROM highways_with_lengths
    GROUP BY "highway_type"
)
SELECT 
    "highway_type",
    "total_length"
FROM aggregated_highways
ORDER BY "total_length" DESC NULLS LAST
LIMIT 5;