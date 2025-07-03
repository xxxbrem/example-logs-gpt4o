WITH denmark_boundary AS (
    -- Extract the geometry of Denmark's boundary using its Wikidata ID ('Q35') and ensure it is a valid multipolygon
    SELECT ST_UNION_AGG(ST_GEOGFROMWKB(t."geometry")) AS "denmark_geometry"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES t, 
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value::VARIANT:"key"::STRING = 'wikidata'
      AND f.value::VARIANT:"value"::STRING = 'Q35'
),
highway_features AS (
    -- Extract highway geometries and their types from PLANET_FEATURES within the Denmark boundary
    SELECT ST_GEOGFROMWKB(t."geometry") AS "geometry", 
           f.value::VARIANT:"value"::STRING AS "highway_type"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES t,
         LATERAL FLATTEN(input => t."all_tags") f,
         denmark_boundary db
    WHERE f.value::VARIANT:"key"::STRING = 'highway'
      AND ST_INTERSECTS(ST_GEOGFROMWKB(t."geometry"), db."denmark_geometry")
),
highway_lengths AS (
    -- Calculate total lengths for each highway type
    SELECT "highway_type",
           SUM(ST_LENGTH("geometry")) AS "total_length_meters"
    FROM highway_features
    GROUP BY "highway_type"
)
-- Retrieve top five longest highway types by total length in Denmark
SELECT "highway_type", 
       "total_length_meters"
FROM highway_lengths
ORDER BY "total_length_meters" DESC NULLS LAST
LIMIT 5;