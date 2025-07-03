WITH AT_STATS AS (
    SELECT 
        MIN("start_position") AS "min_start_position",
        MAX("start_position") AS "max_start_position",
        COUNT(*) AS "total_count"
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
    WHERE "reference_bases" = 'AT'
),
TA_STATS AS (
    SELECT 
        MIN("start_position") AS "min_start_position",
        MAX("start_position") AS "max_start_position",
        COUNT(*) AS "total_count"
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
    WHERE "reference_bases" = 'TA'
),
TOTAL_STATS AS (
    SELECT 
        (SELECT SUM("total_count") FROM AT_STATS) + (SELECT SUM("total_count") FROM TA_STATS) AS "total_variants"
)
SELECT 
    'AT' AS "reference_bases",
    AT_STATS."min_start_position",
    AT_STATS."max_start_position",
    AT_STATS."total_count",
    ROUND(AT_STATS."total_count" * 100.0 / TOTAL_STATS."total_variants", 4) AS "proportion_percentage"
FROM AT_STATS, TOTAL_STATS

UNION ALL

SELECT 
    'TA' AS "reference_bases",
    TA_STATS."min_start_position",
    TA_STATS."max_start_position",
    TA_STATS."total_count",
    ROUND(TA_STATS."total_count" * 100.0 / TOTAL_STATS."total_variants", 4) AS "proportion_percentage"
FROM TA_STATS, TOTAL_STATS;