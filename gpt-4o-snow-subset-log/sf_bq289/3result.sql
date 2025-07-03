WITH philadelphia_places AS (
    SELECT 
        "place_geom"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA
    WHERE "place_name" ILIKE '%Philadelphia%'
),
amenities AS (
    SELECT 
        "osm_id",
        TO_GEOGRAPHY("geometry") AS "amenity_geography",
        "all_tags"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS,
         philadelphia_places
    WHERE ST_CONTAINS(
        TO_GEOGRAPHY(philadelphia_places."place_geom"), TO_GEOGRAPHY("geometry")
    )
    AND (
        "all_tags"::STRING ILIKE '%library%'
        OR "all_tags"::STRING ILIKE '%community%'
        OR "all_tags"::STRING ILIKE '%place%worship%'
    )
),
pairwise_distances AS (
    SELECT 
        a1."osm_id" AS "amenity_1_id",
        a2."osm_id" AS "amenity_2_id",
        ST_DISTANCE(a1."amenity_geography", a2."amenity_geography") AS "distance_meters"
    FROM 
        amenities a1
    CROSS JOIN 
        amenities a2
    WHERE 
        a1."osm_id" <> a2."osm_id"
)
SELECT 
    "amenity_1_id",
    "amenity_2_id",
    "distance_meters"
FROM 
    pairwise_distances
ORDER BY 
    "distance_meters" ASC
LIMIT 1;