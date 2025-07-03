WITH CityPairsDistances AS (
    -- Step 1: Calculate the distance between unique city pairs using the Haversine formula
    SELECT 
        CASE 
            WHEN d1."city" < d2."city" THEN d1."city" 
            ELSE d2."city" 
        END AS "city1",
        CASE 
            WHEN d1."city" < d2."city" THEN d2."city" 
            ELSE d1."city" 
        END AS "city2",
        AVG(
            2 * 6371 * 
            ASIN(SQRT(
                POWER(SIN(RADIANS(SPLIT_PART(REGEXP_REPLACE(d2."coordinates", '[()]', ''), ',', 2)::FLOAT) - 
                           RADIANS(SPLIT_PART(REGEXP_REPLACE(d1."coordinates", '[()]', ''), ',', 2)::FLOAT)) / 2, 2) +
                COS(RADIANS(SPLIT_PART(REGEXP_REPLACE(d1."coordinates", '[()]', ''), ',', 2)::FLOAT)) *
                COS(RADIANS(SPLIT_PART(REGEXP_REPLACE(d2."coordinates", '[()]', ''), ',', 2)::FLOAT)) *
                POWER(SIN(RADIANS(SPLIT_PART(REGEXP_REPLACE(d2."coordinates", '[()]', ''), ',', 1)::FLOAT) - 
                           RADIANS(SPLIT_PART(REGEXP_REPLACE(d1."coordinates", '[()]', ''), ',', 1)::FLOAT)) / 2, 2)
            ))
        ) AS "average_distance"
    FROM AIRLINES.AIRLINES.FLIGHTS f
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA d1 ON f."departure_airport" = d1."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA d2 ON f."arrival_airport" = d2."airport_code"
    GROUP BY 
        CASE 
            WHEN d1."city" < d2."city" THEN d1."city" 
            ELSE d2."city" 
        END,
        CASE 
            WHEN d1."city" < d2."city" THEN d2."city" 
            ELSE d1."city" 
        END
),
BinnedCityPairs AS (
    -- Step 2: Assign each city pair to a distance range
    SELECT 
        "city1",
        "city2",
        "average_distance",
        CASE 
            WHEN "average_distance" < 1000 THEN '0-1000'
            WHEN "average_distance" < 2000 THEN '1000-2000'
            WHEN "average_distance" < 3000 THEN '2000-3000'
            WHEN "average_distance" < 4000 THEN '3000-4000'
            WHEN "average_distance" < 5000 THEN '4000-5000'
            WHEN "average_distance" < 6000 THEN '5000-6000'
            ELSE '6000+'
        END AS "distance_range"
    FROM CityPairsDistances
),
RangeCounts AS (
    -- Step 3: Count the number of city pairs in each distance range
    SELECT 
        "distance_range",
        COUNT(*) AS "city_pairs_count"
    FROM BinnedCityPairs
    GROUP BY "distance_range"
)
-- Step 4: Find the distance range with the fewest unique city pairs
SELECT 
    "distance_range",
    "city_pairs_count"
FROM RangeCounts
ORDER BY "city_pairs_count" ASC
LIMIT 1;