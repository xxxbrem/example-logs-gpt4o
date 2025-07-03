WITH abakan_related_airports AS (
    SELECT "departure_airport", "arrival_airport"
    FROM "AIRLINES"."AIRLINES"."FLIGHTS"
    WHERE "departure_airport" ILIKE '%ABA%'
       OR "arrival_airport" ILIKE '%ABA%'
),
airport_coordinates AS (
    SELECT "airport_code", 
           CAST(SPLIT_PART(REPLACE(REPLACE("coordinates", '(', ''), ')', ''), ',', 1) AS FLOAT) AS longitude, 
           CAST(SPLIT_PART(REPLACE(REPLACE("coordinates", '(', ''), ')', ''), ',', 2) AS FLOAT) AS latitude
    FROM "AIRLINES"."AIRLINES"."AIRPORTS_DATA"
),
abakan_airport_distances AS (
    SELECT DISTINCT ara."departure_airport",
                    ara."arrival_airport",
                    dep_coords.latitude AS dep_lat,
                    dep_coords.longitude AS dep_lon,
                    arr_coords.latitude AS arr_lat,
                    arr_coords.longitude AS arr_lon
    FROM abakan_related_airports ara
    LEFT JOIN airport_coordinates dep_coords
        ON ara."departure_airport" = dep_coords."airport_code"
    LEFT JOIN airport_coordinates arr_coords
        ON ara."arrival_airport" = arr_coords."airport_code"
),
calculated_distances AS (
    SELECT "departure_airport",
           "arrival_airport",
           2 * 6371 * ASIN(SQRT(
               POWER(SIN(RADIANS((arr_lat - dep_lat) / 2)), 2) +
               COS(RADIANS(dep_lat)) * COS(RADIANS(arr_lat)) *
               POWER(SIN(RADIANS((arr_lon - dep_lon) / 2)), 2)
           )) AS distance_km
    FROM abakan_airport_distances
    WHERE dep_lat IS NOT NULL
      AND dep_lon IS NOT NULL
      AND arr_lat IS NOT NULL
      AND arr_lon IS NOT NULL
)
SELECT "departure_airport", 
       "arrival_airport", 
       distance_km
FROM calculated_distances
ORDER BY distance_km DESC NULLS LAST
LIMIT 1;