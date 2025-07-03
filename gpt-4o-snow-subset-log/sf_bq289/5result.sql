SELECT MIN(ST_DISTANCE(TO_GEOMETRY(a."geometry"), TO_GEOMETRY(b."geometry"))) AS "shortest_distance_meters"
FROM GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS a, 
     GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS b, 
     GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA c
WHERE c."place_name" ILIKE '%Philadelphia%'
  AND ST_CONTAINS(TO_GEOMETRY(c."place_geom"), TO_GEOMETRY(a."geometry"))
  AND ST_CONTAINS(TO_GEOMETRY(c."place_geom"), TO_GEOMETRY(b."geometry"))
  AND (a."all_tags"::TEXT ILIKE '%library%' 
       OR a."all_tags"::TEXT ILIKE '%place%of%worship%' 
       OR a."all_tags"::TEXT ILIKE '%community%center%')
  AND (b."all_tags"::TEXT ILIKE '%library%' 
       OR b."all_tags"::TEXT ILIKE '%place%of%worship%' 
       OR b."all_tags"::TEXT ILIKE '%community%center%')
  AND a."osm_id" != b."osm_id";