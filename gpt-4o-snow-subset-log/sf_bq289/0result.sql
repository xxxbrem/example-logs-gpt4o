WITH pair_distances AS (
    SELECT 
        a1."osm_id" AS "amenity1_osm_id", 
        a1."all_tags" AS "amenity1_all_tags",
        a2."osm_id" AS "amenity2_osm_id", 
        a2."all_tags" AS "amenity2_all_tags",
        ST_DISTANCE(TO_GEOGRAPHY(a1."geometry"), TO_GEOGRAPHY(a2."geometry")) AS "distance_meters"
    FROM 
        GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS a1, 
        GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS a2,
        GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA b
    WHERE 
        ST_CONTAINS(TO_GEOGRAPHY(b."place_geom"), TO_GEOGRAPHY(a1."geometry")) 
        AND ST_CONTAINS(TO_GEOGRAPHY(b."place_geom"), TO_GEOGRAPHY(a2."geometry")) 
        AND b."place_name" ILIKE '%Philadelphia%' 
        AND a1."osm_id" != a2."osm_id" 
        AND (
            a1."all_tags"::TEXT ILIKE '%library%' 
            OR a1."all_tags"::TEXT ILIKE '%place_of_worship%' 
            OR a1."all_tags"::TEXT ILIKE '%community_centre%'
        )
        AND (
            a2."all_tags"::TEXT ILIKE '%library%' 
            OR a2."all_tags"::TEXT ILIKE '%place_of_worship%' 
            OR a2."all_tags"::TEXT ILIKE '%community_centre%'
        )
)
SELECT "amenity1_osm_id", "amenity1_all_tags", "amenity2_osm_id", "amenity2_all_tags", "distance_meters"
FROM pair_distances
ORDER BY "distance_meters" ASC
LIMIT 1;