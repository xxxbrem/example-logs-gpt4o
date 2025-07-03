WITH TP53_DATA AS (
    -- Fetch required data for TP53 expression and mutations in TCGA-BRCA
    SELECT 
        r."case_barcode",
        LN(r."normalized_count") / LN(10) AS "log_expression",  -- Log10-transformed expression
        m."Variant_Classification"
    FROM TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.RNASEQ_GENE_EXPRESSION_UNC_RSEM r
    JOIN TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.SOMATIC_MUTATION_MC3 m
      ON r."case_barcode" = m."case_barcode"
    WHERE r."project_short_name" = 'TCGA-BRCA'
      AND r."HGNC_gene_symbol" = 'TP53'
      AND m."Hugo_Symbol" = 'TP53'
      AND r."normalized_count" > 0
),
GROUP_STATS AS (
    -- Calculate group-level statistics
    SELECT
        "Variant_Classification",
        COUNT(*) AS "group_size",
        AVG("log_expression") AS "group_mean"
    FROM TP53_DATA
    GROUP BY "Variant_Classification"
),
OVERALL_STATS AS (
    -- Calculate overall mean
    SELECT 
        COUNT(*) AS "total_samples", 
        AVG("log_expression") AS "grand_mean"
    FROM TP53_DATA
),
SSB_SSW_CALC AS (
    -- Calculate SSB (Sum of Squares Between) and SSW (Sum of Squares Within)
    SELECT 
        SUM(gs."group_size" * POWER(gs."group_mean" - os."grand_mean", 2)) AS "SSB",  -- Between-group variability
        SUM(
            (td."log_expression" - gs."group_mean") * (td."log_expression" - gs."group_mean")
        ) AS "SSW",  -- Within-group variability
        os."total_samples",
        COUNT(gs."Variant_Classification") AS "num_mutation_types"
    FROM TP53_DATA td
    JOIN GROUP_STATS gs 
      ON td."Variant_Classification" = gs."Variant_Classification"
    CROSS JOIN OVERALL_STATS os
    GROUP BY os."total_samples", os."grand_mean"
),
ANOVA_RESULTS AS (
    -- Compute ANOVA components
    SELECT
        sc."total_samples", 
        sc."num_mutation_types",  -- Number of groups (mutation types)
        sc."SSB",
        sc."SSW",
        CASE 
            WHEN (sc."num_mutation_types" - 1) != 0 THEN (sc."SSB" / (sc."num_mutation_types" - 1)) 
            ELSE NULL 
        END AS "MSB",  -- Mean Square Between
        CASE 
            WHEN (sc."total_samples" - sc."num_mutation_types") != 0 THEN (sc."SSW" / (sc."total_samples" - sc."num_mutation_types"))
            ELSE NULL
        END AS "MSW",  -- Mean Square Within
        CASE 
            WHEN (sc."num_mutation_types" - 1) != 0 AND (sc."total_samples" - sc."num_mutation_types") != 0 THEN 
                ((sc."SSB" / (sc."num_mutation_types" - 1)) / (sc."SSW" / (sc."total_samples" - sc."num_mutation_types"))) 
            ELSE NULL 
        END AS "F_statistic"  -- F-statistic
    FROM SSB_SSW_CALC sc
)
SELECT 
    "total_samples",
    "num_mutation_types",
    "MSB",
    "MSW",
    "F_statistic"
FROM ANOVA_RESULTS;