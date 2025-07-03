WITH filtered_amenities AS (
    SELECT 
        t."osm_id",
        f.value::VARIANT:"value"::STRING AS "amenity_type",
        TO_GEOMETRY(t."geometry") AS "amenity_geometry"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS t,
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value::VARIANT:"key"::STRING = 'amenity'
      AND f.value::VARIANT:"value"::STRING IN ('library', 'place_of_worship', 'community_center')
),
philadelphia_boundary AS (
    SELECT TO_GEOMETRY("place_geom") AS "place_boundary"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA
    WHERE "place_name" = 'Philadelphia'
),
amenities_in_philadelphia AS (
    SELECT 
        a.*
    FROM filtered_amenities a
    CROSS JOIN philadelphia_boundary pb
    WHERE ST_CONTAINS(pb."place_boundary", a."amenity_geometry")
),
pairwise_distances AS (
    SELECT 
        a1."osm_id" AS "amenity_1_id",
        a2."osm_id" AS "amenity_2_id",
        a1."amenity_type" AS "amenity_1_type",
        a2."amenity_type" AS "amenity_2_type",
        ST_DISTANCE(a1."amenity_geometry", a2."amenity_geometry") AS "distance"
    FROM amenities_in_philadelphia a1
    JOIN amenities_in_philadelphia a2
    ON a1."osm_id" < a2."osm_id"
)
SELECT 
    "amenity_1_id",
    "amenity_2_id",
    "amenity_1_type",
    "amenity_2_type",
    "distance"
FROM pairwise_distances
ORDER BY "distance" ASC
LIMIT 1;