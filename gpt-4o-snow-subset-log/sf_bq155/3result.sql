WITH Filtered_Cases AS (
  SELECT DISTINCT "case_barcode"
  FROM "TCGA_HG38_DATA_V0"."TCGA_BIOCLIN_V0"."CLINICAL"
  WHERE "project_short_name" = 'TCGA-BRCA'
    AND "age_at_diagnosis" <= 80
    AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
RNA_Log10_Expression AS (
  SELECT r."case_barcode", r."sample_barcode", 
         CASE 
           WHEN (r."HTSeq__Counts" + 1) > 0 THEN LOG(10, CAST(r."HTSeq__Counts" + 1 AS FLOAT)) 
           ELSE NULL 
         END AS "log10_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."RNASEQ_GENE_EXPRESSION" r
  INNER JOIN Filtered_Cases c
  ON r."case_barcode" = c."case_barcode"
  WHERE r."gene_name" = 'SNORA31'
),
miRNA_Average_Expression AS (
  SELECT m."case_barcode", m."sample_barcode", AVG(m."reads_per_million_miRNA_mapped") AS "average_mirna_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."MIRNASEQ_EXPRESSION" m
  INNER JOIN Filtered_Cases c
  ON m."case_barcode" = c."case_barcode"
  GROUP BY m."case_barcode", m."sample_barcode"
),
Correlation_Computation AS (
  SELECT 
    r."log10_expression",
    m."average_mirna_expression"
  FROM RNA_Log10_Expression r
  INNER JOIN miRNA_Average_Expression m
  ON r."sample_barcode" = m."sample_barcode"
  WHERE r."log10_expression" IS NOT NULL
),
Filtered_Correlations AS (
  SELECT 
    COUNT(*) AS "sample_count",
    CORR(r."log10_expression", m."average_mirna_expression") AS "pearson_correlation"
  FROM Correlation_Computation r, Correlation_Computation m
  GROUP BY r."log10_expression", m."average_mirna_expression"
  HAVING COUNT(*) > 25 
     AND ABS(CORR(r."log10_expression", m."average_mirna_expression")) BETWEEN 0.3 AND 1.0
)
SELECT 
  "pearson_correlation",
  "sample_count",
  "pearson_correlation" * SQRT("sample_count" - 2) / SQRT(1 - POWER("pearson_correlation", 2)) AS "t_statistic"
FROM Filtered_Correlations;