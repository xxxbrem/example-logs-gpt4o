WITH philadelphia_geometry AS (
    SELECT 
        "place_geom"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA
    WHERE "place_name" = 'Philadelphia'
),
flattened_amenities AS (
    SELECT
        a."osm_id",
        TO_GEOGRAPHY(a."geometry") AS "amenity_geometry",
        f.value:"key"::STRING AS "key_name",
        f.value:"value"::STRING AS "key_value"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS a,
         philadelphia_geometry p,
         TABLE(FLATTEN(input => a."all_tags")) f
    WHERE ST_CONTAINS(TO_GEOGRAPHY(p."place_geom"), TO_GEOGRAPHY(a."geometry"))
      AND f.value:"key"::STRING = 'amenity'
      AND f.value:"value"::STRING IN ('library', 'place_of_worship', 'community_center')
),
amenity_distances AS (
    SELECT 
        a1."osm_id" AS "amenity_id_1",
        a2."osm_id" AS "amenity_id_2",
        ST_DISTANCE(a1."amenity_geometry", a2."amenity_geometry") AS "distance_meters"
    FROM flattened_amenities a1
    CROSS JOIN flattened_amenities a2
    WHERE a1."osm_id" < a2."osm_id" -- Ensure each pair is only calculated once
)
SELECT 
    "amenity_id_1", 
    "amenity_id_2", 
    "distance_meters"
FROM amenity_distances
ORDER BY "distance_meters" ASC
LIMIT 1;