WITH BRCA_ELIGIBLE_PATIENTS AS (
    -- Selecting eligible patients from the clinical table for TCGA-BRCA
    SELECT DISTINCT
        "case_barcode"
    FROM TCGA_HG38_DATA_V0.TCGA_BIOCLIN_V0.CLINICAL
    WHERE "project_short_name" = 'TCGA-BRCA'
      AND "age_at_diagnosis" <= 80
      AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
SNORA31_LOG_TRANSFORMED_VALUES AS (
    -- Extracting log-transformed RNA-Seq expression levels (LN(HTSeq__Counts + 1)) for the gene SNORA31
    SELECT
        r."sample_barcode",
        LN(r."HTSeq__Counts" + 1) AS "log_transformed_expression"
    FROM TCGA_HG38_DATA_V0.TCGA_HG38_DATA_V0.RNASEQ_GENE_EXPRESSION r
    JOIN BRCA_ELIGIBLE_PATIENTS b
      ON r."sample_barcode" LIKE b."case_barcode" || '%'
    WHERE r."gene_name" = 'SNORA31'
),
AVG_MIRNA_EXPRESSION AS (
    -- Computing average miRNA-Seq expression values for unique miRNAs
    SELECT
        m."mirna_id",
        m."sample_barcode",
        AVG(m."reads_per_million_miRNA_mapped") OVER (PARTITION BY m."mirna_id", m."sample_barcode") AS "avg_mirna_expression"
    FROM TCGA_HG38_DATA_V0.TCGA_HG38_DATA_V0.MIRNASEQ_EXPRESSION m
    JOIN BRCA_ELIGIBLE_PATIENTS b
      ON m."sample_barcode" LIKE b."case_barcode" || '%'
),
PAIRWISE_CORRELATION AS (
    -- Computing Pearson correlation between SNORA31 log-transformed expression and miRNA expression per sample
    SELECT
        s."log_transformed_expression",
        a."avg_mirna_expression",
        a."mirna_id"
    FROM SNORA31_LOG_TRANSFORMED_VALUES s
    JOIN AVG_MIRNA_EXPRESSION a
      ON s."sample_barcode" = a."sample_barcode"
),
FILTERED_CORRELATIONS AS (
    -- Filtering pairs with correlation |r| between 0.3 and 1.0, sample size > 25
    SELECT
        "mirna_id",
        COUNT(*) AS "sample_size",
        CORR("log_transformed_expression", "avg_mirna_expression") AS "pearson_r"
    FROM PAIRWISE_CORRELATION
    GROUP BY "mirna_id"
    HAVING COUNT(*) > 25
       AND ABS(CORR("log_transformed_expression", "avg_mirna_expression")) BETWEEN 0.3 AND 1.0
),
T_STATISTIC_CALCULATION AS (
    -- Calculating the t-statistic based on filtered correlations
    SELECT
        "mirna_id",
        "pearson_r",
        "sample_size",
        ("pearson_r" * SQRT("sample_size" - 2)) / SQRT(1 - POWER("pearson_r", 2)) AS "t_statistic"
    FROM FILTERED_CORRELATIONS
)
-- Outputting results with miRNA, Pearson correlation coefficient, sample size, and t-statistic
SELECT
    "mirna_id",
    "pearson_r",
    "sample_size",
    "t_statistic"
FROM T_STATISTIC_CALCULATION
ORDER BY "t_statistic" DESC NULLS LAST;