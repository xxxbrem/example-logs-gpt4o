WITH Amenity_POIs AS (
  SELECT pn."id", ST_GEOGFROMWKB(pn."geometry") AS "geometry"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES pn,
       LATERAL FLATTEN(input => pn."all_tags") f
  WHERE f.value::VARIANT:"key"::STRING = 'amenity'
),
Boundary_POI_Counts AS (
  SELECT pf."osm_id", COUNT(ap."id") AS "amenity_poi_count"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES pf
  JOIN Amenity_POIs ap
    ON ST_DWITHIN(ST_GEOGFROMWKB(pf."geometry"), ap."geometry", 0)
  WHERE pf."feature_type" = 'multipolygons'
    AND pf."all_tags" ILIKE '%administrative%'
  GROUP BY pf."osm_id"
),
Median_Value AS (
  SELECT APPROX_PERCENTILE("amenity_poi_count", 0.5) AS "median_count"
  FROM Boundary_POI_Counts
)
SELECT bpc."osm_id", bpc."amenity_poi_count"
FROM Boundary_POI_Counts bpc, Median_Value mv
ORDER BY ABS(bpc."amenity_poi_count" - mv."median_count")
LIMIT 1;