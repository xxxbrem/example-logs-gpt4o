WITH philadelphia_polygon AS (
    -- Get the polygon representing the boundaries of Philadelphia
    SELECT "place_geom"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA
    WHERE "place_name" ILIKE '%Philadelphia%'
),
amenity_points AS (
    -- Identify amenities (libraries, places of worship, community centers) within the Philadelphia boundaries
    SELECT 
        t."osm_id",
        TO_GEOGRAPHY(t."geometry") AS "geometry",
        f.value::VARIANT:"value"::STRING AS "amenity"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS t,
         LATERAL FLATTEN(input => t."all_tags") f,
         philadelphia_polygon p
    WHERE f.value::VARIANT:"key"::STRING = 'amenity'
      AND f.value::VARIANT:"value"::STRING IN ('library', 'place of worship', 'community center')
      AND ST_CONTAINS(TO_GEOGRAPHY(p."place_geom"), TO_GEOGRAPHY(t."geometry"))
),
pairwise_distances AS (
    -- Compute all pairwise distances between amenities
    SELECT 
        a1."osm_id" AS "osm_id_1",
        a1."amenity" AS "amenity_1",
        a2."osm_id" AS "osm_id_2",
        a2."amenity" AS "amenity_2",
        ST_DISTANCE(a1."geometry", a2."geometry") AS "distance"
    FROM amenity_points a1
    CROSS JOIN amenity_points a2
    WHERE a1."osm_id" < a2."osm_id"  -- Ensure unique pairs
)
-- Find the shortest distance between two amenities
SELECT 
    "osm_id_1", 
    "amenity_1", 
    "osm_id_2", 
    "amenity_2", 
    "distance"
FROM pairwise_distances
ORDER BY "distance" ASC
LIMIT 1;