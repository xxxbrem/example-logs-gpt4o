WITH denmark_highways AS (
    SELECT 
        f.value::VARIANT:"value"::STRING AS "highway_type", 
        ST_LENGTH(ST_GEOMFROMWKB(t."geometry")) AS "length"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES t,
         LATERAL FLATTEN(input => t."all_tags") f
    WHERE f.value::VARIANT:"key"::STRING = 'highway' 
      AND t."feature_type" = 'lines' 
      AND t."all_tags"::TEXT ILIKE '%Q35%'
)
SELECT 
    "highway_type", 
    SUM("length") AS "total_length"
FROM denmark_highways
GROUP BY "highway_type"
ORDER BY "total_length" DESC NULLS LAST
LIMIT 5;