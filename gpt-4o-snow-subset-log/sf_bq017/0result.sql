SELECT 
    f.value::VARIANT:"value"::STRING AS "highway_type", 
    SUM(ST_LENGTH(ST_GEOGFROMWKB(t."geometry"))) AS "total_length"
FROM 
    GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES t, 
    LATERAL FLATTEN(input => t."all_tags") f
WHERE 
    f.value::VARIANT:"key"::STRING = 'highway'
    AND t."all_tags"::STRING ILIKE '%wikidata%Q35%'
GROUP BY 
    f.value::VARIANT:"value"::STRING
ORDER BY 
    "total_length" DESC NULLS LAST
LIMIT 5;