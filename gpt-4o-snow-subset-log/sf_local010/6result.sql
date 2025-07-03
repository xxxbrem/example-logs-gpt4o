WITH CityPairsWithDistance AS (
    -- Step 1: Extract departure and arrival city coordinates and names.
    SELECT 
        CASE WHEN dep."city"::VARIANT:"en"::STRING < arr."city"::VARIANT:"en"::STRING 
             THEN dep."city"::VARIANT:"en"::STRING ELSE arr."city"::VARIANT:"en"::STRING END AS "city1", 
        CASE WHEN dep."city"::VARIANT:"en"::STRING < arr."city"::VARIANT:"en"::STRING 
             THEN arr."city"::VARIANT:"en"::STRING ELSE dep."city"::VARIANT:"en"::STRING END AS "city2",
        SPLIT_PART(TRIM(dep."coordinates", '()'), ',', 1)::FLOAT AS dep_longitude,
        SPLIT_PART(TRIM(dep."coordinates", '()'), ',', 2)::FLOAT AS dep_latitude,
        SPLIT_PART(TRIM(arr."coordinates", '()'), ',', 1)::FLOAT AS arr_longitude,
        SPLIT_PART(TRIM(arr."coordinates", '()'), ',', 2)::FLOAT AS arr_latitude
    FROM AIRLINES.AIRLINES.FLIGHTS f
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA dep 
      ON f."departure_airport" = dep."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA arr 
      ON f."arrival_airport" = arr."airport_code"
),
CityDistanceWithHaversine AS (
    -- Step 2: Calculate the distance between each city pair using the Haversine formula.
    SELECT 
        "city1", 
        "city2",
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS((arr_latitude - dep_latitude) / 2)), 2) + 
            COS(RADIANS(dep_latitude)) * COS(RADIANS(arr_latitude)) * 
            POWER(SIN(RADIANS((arr_longitude - dep_longitude) / 2)), 2)
        )) AS "distance"
    FROM CityPairsWithDistance
),
AverageCityPairDistance AS (
    -- Step 3: Calculate the average distance for each unique city pair.
    SELECT 
        "city1", 
        "city2", 
        AVG("distance") AS "avg_distance"
    FROM CityDistanceWithHaversine
    GROUP BY "city1", "city2"
),
DistanceRanges AS (
    -- Step 4: Categorize city pairs into predefined distance ranges.
    SELECT 
        "city1", 
        "city2",
        "avg_distance",
        CASE 
            WHEN "avg_distance" <= 1000 THEN '0-1000'
            WHEN "avg_distance" <= 2000 THEN '1001-2000'
            WHEN "avg_distance" <= 3000 THEN '2001-3000'
            WHEN "avg_distance" <= 4000 THEN '3001-4000'
            WHEN "avg_distance" <= 5000 THEN '4001-5000'
            WHEN "avg_distance" <= 6000 THEN '5001-6000'
            ELSE '6000+'
        END AS "distance_range"
    FROM AverageCityPairDistance
),
RangeCounts AS (
    -- Step 5: Count the number of city pairs in each distance range.
    SELECT 
        "distance_range",
        COUNT(*) AS "pair_count"
    FROM DistanceRanges
    GROUP BY "distance_range"
)
-- Step 6: Find the distance range with the fewest unique city pairs.
SELECT 
    "distance_range", 
    "pair_count"
FROM RangeCounts
ORDER BY "pair_count" ASC
LIMIT 1;