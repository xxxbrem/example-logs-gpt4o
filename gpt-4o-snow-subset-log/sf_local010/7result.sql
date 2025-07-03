WITH 
-- Extract and convert departure and arrival coordinates into latitude and longitude
airport_coords AS (
    SELECT 
        "airport_code", 
        SPLIT_PART(SUBSTRING("coordinates", 2, LENGTH("coordinates") - 2), ',', 1)::FLOAT AS "longitude",
        SPLIT_PART(SUBSTRING("coordinates", 2, LENGTH("coordinates") - 2), ',', 2)::FLOAT AS "latitude"
    FROM AIRLINES.AIRLINES.AIRPORTS_DATA
),

-- Join the flights table with the airport_coords table to get coordinates for both departure and arrival airports
flight_coordinates AS (
    SELECT 
        t."flight_id",
        d."latitude" AS "departure_lat",
        d."longitude" AS "departure_lon",
        a."latitude" AS "arrival_lat",
        a."longitude" AS "arrival_lon",
        d."airport_code" AS "departure_airport",
        a."airport_code" AS "arrival_airport"
    FROM AIRLINES.AIRLINES.FLIGHTS t
    JOIN airport_coords d ON t."departure_airport" = d."airport_code"
    JOIN airport_coords a ON t."arrival_airport" = a."airport_code"
),

-- Calculate the distance for each flight using the Haversine formula
flight_distances AS (
    SELECT
        "flight_id",
        "departure_airport",
        "arrival_airport",
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS(("arrival_lat" - "departure_lat") / 2)), 2) +
            COS(RADIANS("departure_lat")) * COS(RADIANS("arrival_lat")) * 
            POWER(SIN(RADIANS(("arrival_lon" - "departure_lon") / 2)), 2)
        )) AS "distance"
    FROM flight_coordinates
),

-- Group by city pairs and calculate the average distance for routes between them
city_distances AS (
    SELECT 
        LEAST(dep."city"::VARIANT:"en"::STRING, arr."city"::VARIANT:"en"::STRING) AS "city1",
        GREATEST(dep."city"::VARIANT:"en"::STRING, arr."city"::VARIANT:"en"::STRING) AS "city2",
        AVG(fd."distance") AS "avg_distance"
    FROM flight_distances fd
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA dep ON fd."departure_airport" = dep."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA arr ON fd."arrival_airport" = arr."airport_code"
    GROUP BY 1, 2
),

-- Categorize each city pair into distance ranges
distance_ranges AS (
    SELECT 
        "city1",
        "city2",
        "avg_distance",
        CASE 
            WHEN "avg_distance" < 1000 THEN '0-1000'
            WHEN "avg_distance" < 2000 THEN '1000-2000'
            WHEN "avg_distance" < 3000 THEN '2000-3000'
            WHEN "avg_distance" < 4000 THEN '3000-4000'
            WHEN "avg_distance" < 5000 THEN '4000-5000'
            WHEN "avg_distance" < 6000 THEN '5000-6000'
            ELSE '6000+'
        END AS "distance_range"
    FROM city_distances
),

-- Count the number of city pairs in each distance range
range_counts AS (
    SELECT 
        "distance_range",
        COUNT(*) AS "pair_count"
    FROM distance_ranges
    GROUP BY "distance_range"
)

-- Find the range with the fewest unique city pairs
SELECT 
    "distance_range",
    "pair_count"
FROM range_counts
ORDER BY "pair_count" ASC
LIMIT 1;