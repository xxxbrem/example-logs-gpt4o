WITH Filtered_Cases AS (
  SELECT DISTINCT "case_barcode"
  FROM "TCGA_HG38_DATA_V0"."TCGA_BIOCLIN_V0"."CLINICAL"
  WHERE "project_short_name" = 'TCGA-BRCA' 
    AND "age_at_diagnosis" <= 80 
    AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
SNORA31_Expression AS (
  SELECT r."sample_barcode", AVG(LN(r."HTSeq__Counts" + 1) / LN(10)) AS "log10_avg_snora31_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."RNASEQ_GENE_EXPRESSION" r
  JOIN Filtered_Cases c ON r."case_barcode" = c."case_barcode"
  WHERE r."gene_name" = 'SNORA31'
  GROUP BY r."sample_barcode"
),
miRNA_Expression AS (
  SELECT m."sample_barcode", m."mirna_id", AVG(m."reads_per_million_miRNA_mapped") AS "avg_mirna_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."MIRNASEQ_EXPRESSION" m
  JOIN Filtered_Cases c ON m."case_barcode" = c."case_barcode"
  GROUP BY m."sample_barcode", m."mirna_id"
),
Expression_Pairs AS (
  SELECT s."log10_avg_snora31_expression", m."avg_mirna_expression", m."mirna_id"
  FROM SNORA31_Expression s
  JOIN miRNA_Expression m ON s."sample_barcode" = m."sample_barcode"
),
Pearson_Correlation AS (
  SELECT 
    "mirna_id",
    CORR("log10_avg_snora31_expression", "avg_mirna_expression") AS "pearson_corr",
    COUNT(*) AS "sample_size"
  FROM Expression_Pairs
  GROUP BY "mirna_id"
  HAVING COUNT(*) > 25
    AND ABS(CORR("log10_avg_snora31_expression", "avg_mirna_expression")) BETWEEN 0.3 AND 1.0
),
T_Statistic AS (
  SELECT 
    "mirna_id",
    "pearson_corr",
    "sample_size",
    ("pearson_corr" * SQRT("sample_size" - 2)) / SQRT(1 - POWER("pearson_corr", 2)) AS "t_statistic"
  FROM Pearson_Correlation
)
SELECT * 
FROM T_Statistic
ORDER BY "t_statistic" DESC NULLS LAST;