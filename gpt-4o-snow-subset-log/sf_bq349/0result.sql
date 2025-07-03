WITH FlattenedFeatures AS (
  -- Extract administrative boundaries with 'boundary=administrative'
  SELECT f."osm_id", f."geometry"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES f,
  LATERAL FLATTEN(input => f."all_tags") fa
  WHERE f."feature_type" = 'multipolygons'
  AND fa.value::VARIANT:"key"::STRING = 'boundary'
  AND fa.value::VARIANT:"value"::STRING = 'administrative'
),
FlattenedNodes AS (
  -- Extract nodes tagged with 'amenity'
  SELECT n."id", n."geometry"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES n,
  LATERAL FLATTEN(input => n."all_tags") na
  WHERE na.value::VARIANT:"key"::STRING = 'amenity'
),
AmenityCounts AS (
  -- Count 'amenity'-tagged POIs for each administrative boundary
  SELECT f."osm_id", COUNT(n."id") AS "amenity_count"
  FROM FlattenedFeatures f
  JOIN FlattenedNodes n
  ON ST_DWITHIN(ST_GEOGFROMWKB(f."geometry"), ST_GEOGFROMWKB(n."geometry"), 1000)
  GROUP BY f."osm_id"
),
MedianValue AS (
  -- Calculate the median POI count
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "amenity_count") AS "median_amenity_count"
  FROM AmenityCounts
)
SELECT a."osm_id", a."amenity_count"
FROM AmenityCounts a, MedianValue m
ORDER BY ABS(a."amenity_count" - m."median_amenity_count")
LIMIT 1;