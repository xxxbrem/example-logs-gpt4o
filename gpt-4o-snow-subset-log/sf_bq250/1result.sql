WITH recent_population_data AS (
    -- Step 1: Retrieve the most recent population grid data for Singapore before January 1, 2023
    SELECT 
        "geo_id",
        "population",
        "longitude_centroid",
        "latitude_centroid",
        ST_GEOGFROMWKB("geog") AS geog,
        "last_updated"
    FROM GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM
    WHERE "country_name" ILIKE '%Singapore%'
      AND "last_updated" = (
          SELECT MAX("last_updated")
          FROM GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM
          WHERE "country_name" ILIKE '%Singapore%' AND "last_updated" < '2023-01-01'
      )
),
bounding_region AS (
    -- Step 2: Aggregate all points into a bounding region using ST_UNION_AGG on converted geometries
    SELECT ST_ENVELOPE(ST_UNION_AGG(geog)) AS bounding_region
    FROM recent_population_data
),
hospitals_in_region AS (
    -- Step 3: Identify hospitals that fall within the bounding region
    SELECT DISTINCT 
        pl."osm_way_id",
        pl."layer_code",
        ST_GEOGFROMWKB(pl."geometry") AS geometry
    FROM GEO_OPENSTREETMAP_WORLDPOP.GEO_OPENSTREETMAP.PLANET_LAYERS pl
    CROSS JOIN bounding_region br
    WHERE pl."layer_code" IN (2110, 2120) -- Filter for hospitals and doctors
      AND ST_INTERSECTS(ST_GEOGFROMWKB(pl."geometry"), br.bounding_region)
),
grid_distances AS (
    -- Step 4: Calculate the distance from each grid cell to the nearest hospital
    SELECT 
        rp."geo_id",
        rp."population",
        rp."longitude_centroid",
        rp."latitude_centroid",
        MIN(ST_DISTANCE(rp.geog, hi.geometry)) AS nearest_hospital_distance
    FROM recent_population_data rp
    CROSS JOIN hospitals_in_region hi
    GROUP BY rp."geo_id", rp."population", rp."longitude_centroid", rp."latitude_centroid"
),
farthest_grid AS (
    -- Step 5: Identify the grid cell that is farthest from any hospital
    SELECT 
        "geo_id",
        "population",
        nearest_hospital_distance
    FROM grid_distances
    ORDER BY nearest_hospital_distance DESC NULLS LAST
    LIMIT 1
)
-- Step 6: Retrieve the total population of the farthest grid cell
SELECT 
    "geo_id",
    "population",
    nearest_hospital_distance
FROM farthest_grid;