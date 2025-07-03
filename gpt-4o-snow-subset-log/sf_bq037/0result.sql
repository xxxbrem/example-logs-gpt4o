WITH Combined_Data AS (
  SELECT 
    "start_position",
    "reference_bases"
  FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
  UNION ALL
  SELECT 
    "start_position",
    "reference_bases"
  FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_VARIANTS_20150220
),
Filtered_Data AS (
  SELECT 
    "start_position",
    "reference_bases"
  FROM Combined_Data
  WHERE "reference_bases" IN ('AT', 'TA')
),
MinMax_Calculations AS (
  SELECT 
    "reference_bases",
    MIN("start_position") AS "min_start",
    MAX("start_position") AS "max_start"
  FROM Filtered_Data
  GROUP BY "reference_bases"
),
Total_Starts AS (
  SELECT 
    COUNT(*) AS total_count
  FROM Filtered_Data
)
SELECT 
  M."reference_bases",
  M."min_start",
  M."max_start",
  M."min_start" * 1.0 / T.total_count AS "min_proportion",
  M."max_start" * 1.0 / T.total_count AS "max_proportion"
FROM MinMax_Calculations M
CROSS JOIN Total_Starts T;