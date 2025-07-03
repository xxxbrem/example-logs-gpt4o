WITH CityPairs AS (
    SELECT 
        LEAST(a1."city", a2."city") AS "city1", 
        GREATEST(a1."city", a2."city") AS "city2",
        CAST(SPLIT_PART(REPLACE(a1."coordinates", '(', ''), ',', 1) AS FLOAT) AS "departure_longitude",
        CAST(SPLIT_PART(REPLACE(REPLACE(a1."coordinates", '(', ''), ')', ''), ',', 2) AS FLOAT) AS "departure_latitude",
        CAST(SPLIT_PART(REPLACE(a2."coordinates", '(', ''), ',', 1) AS FLOAT) AS "arrival_longitude",
        CAST(SPLIT_PART(REPLACE(REPLACE(a2."coordinates", '(', ''), ')', ''), ',', 2) AS FLOAT) AS "arrival_latitude"
    FROM 
        AIRLINES.AIRLINES.FLIGHTS f
    JOIN 
        AIRLINES.AIRLINES.AIRPORTS_DATA a1 
    ON 
        f."departure_airport" = a1."airport_code"
    JOIN 
        AIRLINES.AIRLINES.AIRPORTS_DATA a2 
    ON 
        f."arrival_airport" = a2."airport_code"
), 
Distances AS (
    SELECT 
        "city1",
        "city2",
        AVG(
            2 * 6371 * ASIN(SQRT(
                POWER(SIN(RADIANS(("arrival_latitude" - "departure_latitude") / 2)), 2)
                + COS(RADIANS("departure_latitude")) * COS(RADIANS("arrival_latitude")) 
                * POWER(SIN(RADIANS(("arrival_longitude" - "departure_longitude") / 2)), 2)
            ))
        ) AS "avg_distance"
    FROM 
        CityPairs
    GROUP BY 
        "city1", "city2"
), 
DistanceRanges AS (
    SELECT 
        "city1",
        "city2",
        "avg_distance",
        CASE 
            WHEN "avg_distance" BETWEEN 0 AND 999 THEN '0-1000'
            WHEN "avg_distance" BETWEEN 1000 AND 1999 THEN '1000-2000'
            WHEN "avg_distance" BETWEEN 2000 AND 2999 THEN '2000-3000'
            WHEN "avg_distance" BETWEEN 3000 AND 3999 THEN '3000-4000'
            WHEN "avg_distance" BETWEEN 4000 AND 4999 THEN '4000-5000'
            WHEN "avg_distance" BETWEEN 5000 AND 5999 THEN '5000-6000'
            ELSE '6000+'
        END AS "distance_range"
    FROM 
        Distances
), 
RangeCounts AS (
    SELECT 
        "distance_range",
        COUNT(DISTINCT "city1" || '-' || "city2") AS "pair_count"
    FROM 
        DistanceRanges
    GROUP BY 
        "distance_range"
)
SELECT 
    "distance_range",
    "pair_count"
FROM 
    RangeCounts
WHERE 
    "pair_count" = (
        SELECT MIN("pair_count") FROM RangeCounts
    );