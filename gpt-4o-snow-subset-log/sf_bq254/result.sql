WITH TargetMultipolygon AS (
    -- Retrieve the geometry of the multipolygon associated with Wikidata item Q191.
    SELECT "geometry"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES
    WHERE "feature_type" = 'multipolygons'
    AND "all_tags" ILIKE '%"wikidata","value":"Q191"%'
),
MultipolygonsWithoutWikidata AS (
    -- Get multipolygons without a 'wikidata' tag but within the same geographic area as the target multipolygon.
    SELECT pf."osm_id", pf."geometry", pf."all_tags"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES pf
    CROSS JOIN TargetMultipolygon tm
    WHERE pf."feature_type" = 'multipolygons'
    AND pf."all_tags" NOT ILIKE '%wikidata%'
    AND ST_DWITHIN(TO_GEOGRAPHY(pf."geometry"), TO_GEOGRAPHY(tm."geometry"), 100000) -- Assuming 100km radius based on relevance.
),
PointsWithinMultipolygons AS (
    -- Determine the number of points falling within the boundaries of each multipolygon.
    SELECT 
        mw."osm_id" AS multipolygon_id,
        COUNT(p."osm_id") AS points_count
    FROM MultipolygonsWithoutWikidata mw
    JOIN GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS p
    ON ST_CONTAINS(TO_GEOGRAPHY(mw."geometry"), TO_GEOGRAPHY(p."geometry"))
    GROUP BY mw."osm_id"
),
TopMultipolygons AS (
    -- Rank and filter the top two multipolygons by the number of points contained within their boundaries.
    SELECT 
        mw."osm_id", 
        mw."all_tags", 
        pw.points_count
    FROM MultipolygonsWithoutWikidata mw
    JOIN PointsWithinMultipolygons pw
    ON mw."osm_id" = pw.multipolygon_id
    ORDER BY pw.points_count DESC NULLS LAST
    LIMIT 2
)
-- Final result: retrieve the names (if available) and IDs of the top two multipolygons.
SELECT 
    tm."osm_id", 
    JSON_EXTRACT_PATH_TEXT(tm."all_tags", 'name') AS "name", 
    tm.points_count
FROM TopMultipolygons tm;