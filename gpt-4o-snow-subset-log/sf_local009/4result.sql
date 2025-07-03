SELECT MAX(ST_DISTANCE(
            ST_MAKEPOINT(CAST(SPLIT_PART(TRIM(d."coordinates", '()'), ',', 1) AS FLOAT), CAST(SPLIT_PART(TRIM(d."coordinates", '()'), ',', 2) AS FLOAT)),
            ST_MAKEPOINT(CAST(SPLIT_PART(TRIM(a."coordinates", '()'), ',', 1) AS FLOAT), CAST(SPLIT_PART(TRIM(a."coordinates", '()'), ',', 2) AS FLOAT))
        ) * 6371) AS "longest_distance_km"
FROM "AIRLINES"."AIRLINES"."FLIGHTS" t1
LEFT JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" d 
       ON t1."departure_airport" = d."airport_code"
LEFT JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" a 
       ON t1."arrival_airport" = a."airport_code"
WHERE t1."departure_airport" = 'ABA'
   OR t1."arrival_airport" = 'ABA';