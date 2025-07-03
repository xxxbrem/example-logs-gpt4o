WITH amenity_poi_counts AS (
    -- Count the number of 'amenity'-tagged POIs for each node
    SELECT 
        t."id" AS "node_id",
        t."latitude",
        t."longitude",
        COUNT(*) AS "poi_count"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES t, 
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value:"key"::STRING ILIKE '%amenity%'
    GROUP BY t."id", t."latitude", t."longitude"
),
boundary_pois AS (
    -- Map each administrative boundary to the total number of 'amenity'-tagged POIs within its boundaries
    SELECT 
        f."osm_id" AS "boundary_id",
        SUM(apc."poi_count") AS "total_pois"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES f
    JOIN amenity_poi_counts apc
    ON ST_DWITHIN(
        ST_MAKEPOINT(apc."longitude"::DOUBLE, apc."latitude"::DOUBLE),
        TO_GEOGRAPHY(f."geometry"),
        0
    ) -- Ensuring 'amenity' nodes fall within the boundary
    WHERE f."feature_type" = 'multipolygons'
      AND f."all_tags" ILIKE '%administrative%'
    GROUP BY f."osm_id"
),
median_poi_calculation AS (
    -- Calculate the median number of POIs across all administrative boundaries
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "total_pois") AS "median_pois"
    FROM boundary_pois
),
closest_to_median AS (
    -- Find the boundary whose POI count is closest to the median
    SELECT 
        b."boundary_id",
        b."total_pois",
        ABS(b."total_pois" - m."median_pois") AS "distance_to_median"
    FROM boundary_pois b
    CROSS JOIN median_poi_calculation m
    ORDER BY "distance_to_median" ASC
    FETCH FIRST 1 ROWS ONLY
)
-- Return the result
SELECT "boundary_id", "total_pois"
FROM closest_to_median;