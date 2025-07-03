WITH amenity_pois AS (
    -- Count the number of 'amenity'-tagged POIs for each administrative boundary
    SELECT
        pf."osm_way_id" AS "boundary_osm_way_id",
        COUNT(*) AS "amenity_count"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES pf
    JOIN GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES pn
        ON ST_DWITHIN(
            ST_GEOGFROMWKB(pf."geometry"), 
            ST_MAKEPOINT(pn."longitude", pn."latitude"), 
            10000 -- 10 km distance for association
        )
    WHERE
        pf."feature_type" = 'multipolygons'
        AND pf."all_tags" ILIKE '%"boundary"%'
        AND pf."all_tags" ILIKE '%"administrative"%'
        AND pn."all_tags" ILIKE '%amenity%'
    GROUP BY pf."osm_way_id"
),
median_calculation AS (
    -- Calculate the median of amenity counts
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "amenity_count") AS "median_count"
    FROM amenity_pois
),
closest_to_median AS (
    -- Find the administrative boundary closest to the median number of amenities
    SELECT
        "boundary_osm_way_id",
        "amenity_count",
        ABS("amenity_count" - mc."median_count") AS "deviation_from_median"
    FROM amenity_pois, median_calculation mc
    ORDER BY "deviation_from_median" ASC
    LIMIT 1
)
-- Output the OpenStreetMap ID that fits the criteria
SELECT "boundary_osm_way_id", "amenity_count"
FROM closest_to_median;