WITH AbakanFlights AS (
    SELECT f."flight_id", 
           dep."coordinates" AS "departure_coordinates", 
           arr."coordinates" AS "arrival_coordinates"
    FROM "AIRLINES"."AIRLINES"."FLIGHTS" f
    JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" dep 
        ON f."departure_airport" = dep."airport_code"
    JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" arr 
        ON f."arrival_airport" = arr."airport_code"
    WHERE f."departure_airport" = 'ABA' OR f."arrival_airport" = 'ABA'
),
ParsedCoordinates AS (
    SELECT "flight_id",
           CAST(SPLIT_PART(REPLACE(REPLACE("departure_coordinates", '(', ''), ')', ''), ',', 1) AS FLOAT) AS "dep_longitude",
           CAST(SPLIT_PART(REPLACE(REPLACE("departure_coordinates", '(', ''), ')', ''), ',', 2) AS FLOAT) AS "dep_latitude",
           CAST(SPLIT_PART(REPLACE(REPLACE("arrival_coordinates", '(', ''), ')', ''), ',', 1) AS FLOAT) AS "arr_longitude",
           CAST(SPLIT_PART(REPLACE(REPLACE("arrival_coordinates", '(', ''), ')', ''), ',', 2) AS FLOAT) AS "arr_latitude"
    FROM AbakanFlights
),
CalculatedDistances AS (
    SELECT "flight_id",
           ST_DISTANCE(
               ST_POINT("dep_longitude", "dep_latitude"),
               ST_POINT("arr_longitude", "arr_latitude")
           ) / 1000 AS "distance_km" -- Convert from meters to kilometers
    FROM ParsedCoordinates
)
SELECT MAX("distance_km") AS "longest_distance_km"
FROM CalculatedDistances;