SELECT 
  f."flight_id", 
  f."flight_no", 
  2 * 6371 * ASIN(SQRT(POWER(SIN(RADIANS(
    SPLIT_PART(REPLACE(REPLACE(a."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT - 
    SPLIT_PART(REPLACE(REPLACE(d."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT)/2), 2) + 
    COS(RADIANS(SPLIT_PART(REPLACE(REPLACE(d."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT)) * 
    COS(RADIANS(SPLIT_PART(REPLACE(REPLACE(a."coordinates", '(', ''), ')', ''), ',', 2)::FLOAT)) * 
    POWER(SIN(RADIANS(
      SPLIT_PART(REPLACE(REPLACE(a."coordinates", '(', ''), ')', ''), ',', 1)::FLOAT - 
      SPLIT_PART(REPLACE(REPLACE(d."coordinates", '(', ''), ')', ''), ',', 1)::FLOAT)/2), 2)
  )) AS "distance_km" 
FROM AIRLINES.AIRLINES.FLIGHTS f 
LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA d 
  ON f."departure_airport" = d."airport_code" 
LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA a 
  ON f."arrival_airport" = a."airport_code" 
WHERE f."departure_airport" = 'ABA' OR f."arrival_airport" = 'ABA' 
ORDER BY "distance_km" DESC NULLS LAST 
LIMIT 1;