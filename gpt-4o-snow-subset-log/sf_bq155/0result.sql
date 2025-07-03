WITH clinical_filtered AS (
  SELECT DISTINCT "case_barcode"
  FROM "TCGA_HG38_DATA_V0"."TCGA_BIOCLIN_V0"."CLINICAL"
  WHERE "project_short_name" = 'TCGA-BRCA'
    AND "age_at_diagnosis" <= 80
    AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
rna_expression AS (
  SELECT 
    r."sample_barcode",
    (LN(AVG(r."HTSeq__Counts" + 1)) / LN(10)) AS "avg_log10_rna_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."RNASEQ_GENE_EXPRESSION" r
  WHERE r."project_short_name" = 'TCGA-BRCA'
    AND r."gene_name" = 'SNORA31'
    AND r."case_barcode" IN (SELECT "case_barcode" FROM clinical_filtered)
  GROUP BY r."sample_barcode"
),
mirna_expression AS (
  SELECT 
    m."sample_barcode",
    m."mirna_id",
    AVG(m."reads_per_million_miRNA_mapped") AS "avg_mirna_expression"
  FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."MIRNASEQ_EXPRESSION" m
  WHERE m."project_short_name" = 'TCGA-BRCA'
    AND m."case_barcode" IN (SELECT "case_barcode" FROM clinical_filtered)
  GROUP BY m."sample_barcode", m."mirna_id"
),
joined_data AS (
  SELECT 
    r."sample_barcode",
    r."avg_log10_rna_expression",
    m."mirna_id",
    m."avg_mirna_expression"
  FROM rna_expression r
  JOIN mirna_expression m
  ON r."sample_barcode" = m."sample_barcode"
),
correlation_data AS (
  SELECT 
    "mirna_id",
    CORR("avg_log10_rna_expression", "avg_mirna_expression") AS "pearson_correlation",
    COUNT(*) AS "sample_count"
  FROM joined_data
  GROUP BY "mirna_id"
  HAVING COUNT(*) > 25
    AND ABS(CORR("avg_log10_rna_expression", "avg_mirna_expression")) BETWEEN 0.3 AND 1.0
)
SELECT 
  "mirna_id",
  "pearson_correlation",
  "sample_count",
  "pearson_correlation" * SQRT("sample_count" - 2) / SQRT(1 - POWER("pearson_correlation", 2)) AS "t_statistic"
FROM correlation_data
LIMIT 20;