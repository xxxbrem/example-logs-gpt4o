WITH ADMIN_BOUNDARIES AS (
    SELECT 
        "osm_id",
        "osm_way_id",
        "geometry",
        f.value::VARIANT:"key"::STRING AS "tag_key",
        f.value::VARIANT:"value"::STRING AS "tag_value"
    FROM "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES" t, 
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE t."feature_type" = 'multipolygons'
      AND f.value::VARIANT:"key"::STRING = 'boundary'
      AND f.value::VARIANT:"value"::STRING = 'administrative'
), AMENITY_TAGGED_POIS AS (
    SELECT 
        t."id",
        f.value::VARIANT:"key"::STRING AS "tag_key",
        f.value::VARIANT:"value"::STRING AS "tag_value",
        t."latitude",
        t."longitude"
    FROM "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_NODES" t,
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value::VARIANT:"key"::STRING = 'amenity'
), COUNT_AMENITIES_PER_ADMIN AS (
    SELECT 
        a."osm_id",
        COUNT(p."id") AS "amenity_count"
    FROM ADMIN_BOUNDARIES a
    JOIN AMENITY_TAGGED_POIS p
      ON ST_WITHIN(
            ST_POINT(p."longitude"::FLOAT, p."latitude"::FLOAT), 
            TO_GEOGRAPHY(a."geometry")
         )
    GROUP BY a."osm_id"
), MEDIAN_AMENITY_COUNT AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "amenity_count") AS "median_count"
    FROM COUNT_AMENITIES_PER_ADMIN
)
SELECT 
    t."osm_id"
FROM COUNT_AMENITIES_PER_ADMIN t, MEDIAN_AMENITY_COUNT m
ORDER BY ABS(t."amenity_count" - m."median_count")
LIMIT 1;