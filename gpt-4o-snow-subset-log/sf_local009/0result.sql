WITH Abakan_Flights AS (
    SELECT f."flight_id", 
           REPLACE(REPLACE(da."coordinates", '(', ''), ')', '') AS "departure_coordinates", 
           REPLACE(REPLACE(aa."coordinates", '(', ''), ')', '') AS "arrival_coordinates"
    FROM AIRLINES.AIRLINES.FLIGHTS f
    LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA da ON f."departure_airport" = da."airport_code"
    LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA aa ON f."arrival_airport" = aa."airport_code"
    WHERE da."city" ILIKE '%Abakan%' OR aa."city" ILIKE '%Abakan%'
),
Coordinates_Parsed AS (
    SELECT "flight_id",
           SPLIT_PART("departure_coordinates", ',', 1)::FLOAT AS "dep_longitude",
           SPLIT_PART("departure_coordinates", ',', 2)::FLOAT AS "dep_latitude",
           SPLIT_PART("arrival_coordinates", ',', 1)::FLOAT AS "arr_longitude",
           SPLIT_PART("arrival_coordinates", ',', 2)::FLOAT AS "arr_latitude"
    FROM Abakan_Flights
),
Distance_Calculated AS (
    SELECT "flight_id",
           2 * 6371 * ASIN(SQRT(
               POW(SIN(RADIANS(("arr_latitude" - "dep_latitude") / 2)), 2) +
               COS(RADIANS("dep_latitude")) * COS(RADIANS("arr_latitude")) *
               POW(SIN(RADIANS(("arr_longitude" - "dep_longitude") / 2)), 2)
           )) AS "distance_km"
    FROM Coordinates_Parsed
)
SELECT MAX("distance_km") AS "longest_distance_km"
FROM Distance_Calculated;