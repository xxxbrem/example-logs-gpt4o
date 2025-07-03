WITH abakan_coordinates AS (
    SELECT 
        CAST(SPLIT_PART(SPLIT_PART("coordinates", '(', 2), ',', 1) AS FLOAT) AS longitude,
        CAST(SPLIT_PART(SPLIT_PART("coordinates", ',', 2), ')', 1) AS FLOAT) AS latitude,
        "airport_code"
    FROM "AIRLINES"."AIRLINES"."AIRPORTS_DATA"
    WHERE "city" ILIKE '%Abakan%'
),
departure_airport_data AS (
    SELECT 
        "airport_code" AS dep_airport_code,
        CAST(SPLIT_PART(SPLIT_PART("coordinates", '(', 2), ',', 1) AS FLOAT) AS dep_longitude,
        CAST(SPLIT_PART(SPLIT_PART("coordinates", ',', 2), ')', 1) AS FLOAT) AS dep_latitude
    FROM "AIRLINES"."AIRLINES"."AIRPORTS_DATA"
),
arrival_airport_data AS (
    SELECT 
        "airport_code" AS arr_airport_code,
        CAST(SPLIT_PART(SPLIT_PART("coordinates", '(', 2), ',', 1) AS FLOAT) AS arr_longitude,
        CAST(SPLIT_PART(SPLIT_PART("coordinates", ',', 2), ')', 1) AS FLOAT) AS arr_latitude
    FROM "AIRLINES"."AIRLINES"."AIRPORTS_DATA"
),
flight_coordinates AS (
    SELECT 
        f."flight_id",
        dep.dep_longitude AS departure_longitude,
        dep.dep_latitude AS departure_latitude,
        arr.arr_longitude AS arrival_longitude,
        arr.arr_latitude AS arrival_latitude
    FROM "AIRLINES"."AIRLINES"."FLIGHTS" f
    JOIN departure_airport_data dep ON f."departure_airport" = dep.dep_airport_code
    JOIN arrival_airport_data arr ON f."arrival_airport" = arr.arr_airport_code
    WHERE f."departure_airport" IN (SELECT "airport_code" FROM abakan_coordinates)
       OR f."arrival_airport" IN (SELECT "airport_code" FROM abakan_coordinates)
),
distances AS (
    SELECT 
        "flight_id",
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS((arrival_latitude - departure_latitude) / 2)), 2) +
            COS(RADIANS(departure_latitude)) * COS(RADIANS(arrival_latitude)) *
            POWER(SIN(RADIANS((arrival_longitude - departure_longitude) / 2)), 2)
        )) AS distance_km
    FROM flight_coordinates
)
SELECT 
    MAX(distance_km) AS longest_route_distance_km
FROM distances;