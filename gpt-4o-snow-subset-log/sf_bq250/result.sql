WITH latest_population_grid_sg AS (
    -- Step 1: Get the most recent population grid data in Singapore before January 2023
    SELECT 
        "geo_id", 
        "population", 
        "longitude_centroid", 
        "latitude_centroid", 
        ST_GEOGFROMWKB("geog") AS geog_geometry
    FROM 
        GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM 
    WHERE 
        "alpha_3_code" = 'SGP' 
        AND "last_updated" = (
            SELECT MAX("last_updated") 
            FROM GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM 
            WHERE "alpha_3_code" = 'SGP' AND "last_updated" < '2023-01-01'
        )
),
population_bounding_region AS (
    -- Step 2: Aggregate all population grid centroids into a bounding envelope
    SELECT 
        ST_ENVELOPE(ST_UNION_AGG(geog_geometry)) AS bounding_region
    FROM 
        latest_population_grid_sg
),
hospitals_in_bounding_region AS (
    -- Step 3: Identify hospitals from OpenStreetMap’s layer that fall within the bounding region
    SELECT 
        ST_GEOGFROMWKB(p."geometry") AS hospital_geometry
    FROM 
        GEO_OPENSTREETMAP_WORLDPOP.GEO_OPENSTREETMAP.PLANET_LAYERS AS p, 
        population_bounding_region AS b
    WHERE 
        p."layer_code" IN (2110, 2120) -- 2110 = hospital, 2120 = doctors
        AND ST_INTERSECTS(ST_GEOGFROMWKB(p."geometry"), b.bounding_region)
),
distance_to_nearest_hospital AS (
    -- Step 4: Calculate distance of each grid cell to its nearest hospital
    SELECT
        g."geo_id",
        g."population",
        MIN(ST_DISTANCE(g.geog_geometry, h.hospital_geometry)) AS min_distance
    FROM 
        latest_population_grid_sg AS g
    CROSS JOIN 
        hospitals_in_bounding_region AS h
    GROUP BY 
        g."geo_id", g."population"
),
farthest_grid_cell AS (
    -- Step 5: Identify the grid cell that is farthest from any hospital
    SELECT 
        "geo_id",
        "population",
        MAX(min_distance) AS max_distance
    FROM 
        distance_to_nearest_hospital
    GROUP BY 
        "geo_id", "population"
    ORDER BY 
        max_distance DESC NULLS LAST
    LIMIT 1
)
-- Step 6: Return the total population of the farthest grid cell
SELECT 
    "geo_id",
    "population",
    max_distance AS distance_to_nearest_hospital
FROM 
    farthest_grid_cell;