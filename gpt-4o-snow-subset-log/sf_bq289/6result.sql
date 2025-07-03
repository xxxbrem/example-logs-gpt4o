WITH filtered_amenities AS (
  SELECT DISTINCT 
      a."osm_id", 
      ST_GEOMETRYFROMWKB(a."geometry") AS "amenity_geometry"
  FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS a,
       GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA p, 
       LATERAL FLATTEN(input => a."all_tags") f
  WHERE ST_CONTAINS(ST_GEOMETRYFROMWKB(p."place_geom"), ST_GEOMETRYFROMWKB(a."geometry"))
    AND p."place_name" = 'Philadelphia'
    AND (
         f.value::VARIANT:"value"::STRING ILIKE '%library%'
         OR f.value::VARIANT:"value"::STRING ILIKE '%worship%'
         OR f.value::VARIANT:"value"::STRING ILIKE '%community%'
    )
)
SELECT 
    a1."osm_id" AS amenity_1_id, 
    a2."osm_id" AS amenity_2_id, 
    ST_DISTANCE(a1."amenity_geometry", a2."amenity_geometry") AS distance_meters
FROM filtered_amenities a1
CROSS JOIN filtered_amenities a2
WHERE a1."osm_id" <> a2."osm_id"
ORDER BY distance_meters ASC
LIMIT 1;