WITH CityPairs AS (
    -- Step 1: Extract coordinates for departure and arrival cities and calculate distance for each flight
    SELECT 
        SPLIT_PART(REPLACE(REPLACE(d."coordinates", '(', ''), ')', ''), ',', 1)::FLOAT AS "departure_longitude",
        SPLIT_PART(REPLACE(REPLACE(d."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT AS "departure_latitude",
        SPLIT_PART(REPLACE(REPLACE(a."coordinates", '(', ''), ')', ''), ',', 1)::FLOAT AS "arrival_longitude",
        SPLIT_PART(REPLACE(REPLACE(a."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT AS "arrival_latitude",
        LEAST(d."city"::VARIANT:"en"::STRING, a."city"::VARIANT:"en"::STRING) AS "city1",
        GREATEST(d."city"::VARIANT:"en"::STRING, a."city"::VARIANT:"en"::STRING) AS "city2",
        f."flight_id"
    FROM AIRLINES.AIRLINES.FLIGHTS f
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA d 
        ON f."departure_airport" = d."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA a 
        ON f."arrival_airport" = a."airport_code"
),
Distances AS (
    -- Step 2: Use the Haversine formula to calculate the flight distance
    SELECT
        "city1",
        "city2",
        "flight_id",
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS(("arrival_latitude" - "departure_latitude") / 2)), 2) +
            COS(RADIANS("departure_latitude")) * COS(RADIANS("arrival_latitude")) *
            POWER(SIN(RADIANS(("arrival_longitude" - "departure_longitude") / 2)), 2)
        )) AS "distance"
    FROM CityPairs
),
AverageDistances AS (
    -- Step 3: Compute the average flight distance for each unique city pair
    SELECT
        "city1",
        "city2",
        ROUND(AVG("distance"), 4) AS "average_distance"
    FROM Distances
    GROUP BY "city1", "city2"
),
DistanceRanges AS (
    -- Step 4: Categorize city pairs into distance ranges
    SELECT
        "city1",
        "city2",
        "average_distance",
        CASE
            WHEN "average_distance" <= 1000 THEN '0-1000'
            WHEN "average_distance" <= 2000 THEN '1000-2000'
            WHEN "average_distance" <= 3000 THEN '2000-3000'
            WHEN "average_distance" <= 4000 THEN '3000-4000'
            WHEN "average_distance" <= 5000 THEN '4000-5000'
            WHEN "average_distance" <= 6000 THEN '5000-6000'
            ELSE '6000+'
        END AS "distance_range"
    FROM AverageDistances
),
RangeCounts AS (
    -- Step 5: Count the number of city pairs in each distance range
    SELECT
        "distance_range",
        COUNT(*) AS "city_pair_count"
    FROM DistanceRanges
    GROUP BY "distance_range"
)
-- Step 6: Retrieve the count for the range with the fewest city pairs
SELECT 
    "distance_range",
    "city_pair_count"
FROM RangeCounts
ORDER BY "city_pair_count" ASC NULLS LAST
LIMIT 1;