SELECT 
    "reference_base", 
    MIN("start_position") AS "min_start_position", 
    MAX("start_position") AS "max_start_position",
    ROUND((MIN("start_position")::FLOAT / max_overall_start_position), 8) AS "proportion_min_start",
    ROUND((MAX("start_position")::FLOAT / max_overall_start_position), 8) AS "proportion_max_start"
FROM (
    SELECT 
        'AT' AS "reference_base",
        "start_position",
        MAX("start_position") OVER() AS max_overall_start_position
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
    WHERE "reference_bases" = 'AT'
    UNION ALL
    SELECT 
        'TA' AS "reference_base",
        "start_position",
        MAX("start_position") OVER() AS max_overall_start_position
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
    WHERE "reference_bases" = 'TA'
) AS subquery
GROUP BY "reference_base", max_overall_start_position;