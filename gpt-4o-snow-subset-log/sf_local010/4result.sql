WITH cleaned_coordinates AS (
    SELECT 
        f."flight_id",
        d."city"::VARIANT:"en"::STRING AS "departure_city",
        a."city"::VARIANT:"en"::STRING AS "arrival_city",
        CAST(SPLIT_PART(REGEXP_REPLACE(d."coordinates", '[()]', ''), ',', 1) AS FLOAT) AS "departure_longitude",
        CAST(SPLIT_PART(REGEXP_REPLACE(d."coordinates", '[()]', ''), ',', 2) AS FLOAT) AS "departure_latitude",
        CAST(SPLIT_PART(REGEXP_REPLACE(a."coordinates", '[()]', ''), ',', 1) AS FLOAT) AS "arrival_longitude",
        CAST(SPLIT_PART(REGEXP_REPLACE(a."coordinates", '[()]', ''), ',', 2) AS FLOAT) AS "arrival_latitude"
    FROM AIRLINES.AIRLINES.FLIGHTS f
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA d
    ON f."departure_airport" = d."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA a
    ON f."arrival_airport" = a."airport_code"
),
calculated_distances AS (
    SELECT 
        CASE 
            WHEN c."departure_city" < c."arrival_city" THEN c."departure_city" 
            ELSE c."arrival_city" 
        END AS "city1",
        CASE 
            WHEN c."departure_city" < c."arrival_city" THEN c."arrival_city" 
            ELSE c."departure_city" 
        END AS "city2",
        (6371 * 2 * 
        ASIN(SQRT(POWER(SIN((c."arrival_latitude" - c."departure_latitude") * PI() / 180 / 2), 2) + 
        COS(c."departure_latitude" * PI() / 180) * COS(c."arrival_latitude" * PI() / 180) * 
        POWER(SIN((c."arrival_longitude" - c."departure_longitude") * PI() / 180 / 2), 2)))) AS "distance_km"
    FROM cleaned_coordinates c
),
average_distances AS (
    SELECT 
        "city1",
        "city2",
        AVG("distance_km") AS "average_distance_km"
    FROM calculated_distances
    GROUP BY "city1", "city2"
),
distance_ranges AS (
    SELECT 
        CASE 
            WHEN "average_distance_km" <= 1000 THEN '0-1000'
            WHEN "average_distance_km" <= 2000 THEN '1000-2000'
            WHEN "average_distance_km" <= 3000 THEN '2000-3000'
            WHEN "average_distance_km" <= 4000 THEN '3000-4000'
            WHEN "average_distance_km" <= 5000 THEN '4000-5000'
            ELSE '6000+'
        END AS "distance_range",
        COUNT(*) AS "city_pair_count"
    FROM average_distances
    GROUP BY "distance_range"
)
SELECT "distance_range", "city_pair_count"
FROM distance_ranges
ORDER BY "city_pair_count" ASC
LIMIT 1;