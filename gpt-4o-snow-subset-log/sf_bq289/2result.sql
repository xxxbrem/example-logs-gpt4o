WITH amenities AS (
    SELECT
        t."osm_id",
        ST_X(TO_GEOMETRY(t."geometry")) AS "longitude",
        ST_Y(TO_GEOMETRY(t."geometry")) AS "latitude",
        t."all_tags"
    FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES."PLACES_PENNSYLVANIA" p,
         GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP."PLANET_FEATURES_POINTS" t
    WHERE p."place_name" = 'Philadelphia'
      AND ST_CONTAINS(TO_GEOMETRY(p."place_geom"), TO_GEOMETRY(t."geometry"))
      AND (
          t."all_tags" ILIKE '%library%' OR 
          t."all_tags" ILIKE '%place%worship%' OR 
          t."all_tags" ILIKE '%community%center%'
      )
)
SELECT 
    a1."osm_id" AS "amenity_1", 
    a2."osm_id" AS "amenity_2",
    ST_DISTANCE(ST_POINT(a1."longitude", a1."latitude"), ST_POINT(a2."longitude", a2."latitude")) AS "distance_meters"
FROM amenities a1
JOIN amenities a2
    ON a1."osm_id" < a2."osm_id"
ORDER BY "distance_meters" ASC
LIMIT 1;