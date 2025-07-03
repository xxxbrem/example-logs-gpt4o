WITH BoundaryPOICounts AS (
    SELECT 
        pf."osm_id" AS "boundary_osm_id", 
        COUNT(pn."id") AS "poi_count"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES pf
    JOIN GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES pn
    ON ST_DWITHIN(ST_GEOGFROMWKB(pn."geometry"), ST_GEOGFROMWKB(pf."geometry"), 100) 
    WHERE pf."feature_type" = 'multipolygons' 
      AND pf."all_tags" ILIKE '%"boundary","value":"administrative"%'
      AND pn."all_tags" ILIKE '%"key":"amenity"%'
    GROUP BY pf."osm_id"
),
MedianPOI AS (
    SELECT APPROX_PERCENTILE("poi_count", 0.5) AS "median_poi_count"
    FROM BoundaryPOICounts
),
BoundaryClosestToMedian AS (
    SELECT 
        bpc."boundary_osm_id", 
        bpc."poi_count", 
        ABS(bpc."poi_count" - mp."median_poi_count") AS "distance_to_median"
    FROM BoundaryPOICounts bpc
    CROSS JOIN MedianPOI mp
    ORDER BY "distance_to_median" ASC
    LIMIT 1
)
SELECT "boundary_osm_id", "poi_count"
FROM BoundaryClosestToMedian;