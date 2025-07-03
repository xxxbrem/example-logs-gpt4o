WITH Coordinates AS (
    SELECT 
        f."flight_id",
        ad1."city" AS "departure_city",
        ad2."city" AS "arrival_city",
        ST_POINT(
            SPLIT_PART(REPLACE(ad1."coordinates", '(', ''), ',', 1)::FLOAT,
            SPLIT_PART(REPLACE(REPLACE(ad1."coordinates", ')', ''), '(', ''), ',', 2)::FLOAT
        ) AS "departure_point",
        ST_POINT(
            SPLIT_PART(REPLACE(ad2."coordinates", '(', ''), ',', 1)::FLOAT,
            SPLIT_PART(REPLACE(REPLACE(ad2."coordinates", ')', ''), '(', ''), ',', 2)::FLOAT
        ) AS "arrival_point"
    FROM AIRLINES.AIRLINES.FLIGHTS f
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA ad1 ON f."departure_airport" = ad1."airport_code"
    JOIN AIRLINES.AIRLINES.AIRPORTS_DATA ad2 ON f."arrival_airport" = ad2."airport_code"
    WHERE ad1."city" ILIKE '%Abakan%' OR ad2."city" ILIKE '%Abakan%'
),
Distances AS (
    SELECT 
        "flight_id",
        "departure_city",
        "arrival_city",
        ST_DISTANCE("departure_point", "arrival_point") / 1000 AS "distance_km"
    FROM Coordinates
)
SELECT 
    "flight_id",
    "departure_city",
    "arrival_city",
    "distance_km"
FROM Distances
ORDER BY "distance_km" DESC NULLS LAST
LIMIT 1;