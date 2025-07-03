WITH ExpressionMutationData AS (
    -- Combine TP53 expression data and mutation data, matching samples by case barcode
    SELECT 
        expr."case_barcode", 
        expr."sample_barcode", 
        mut."Variant_Classification", 
        LN(expr."normalized_count") / LN(10) AS "log10_expression" -- Use LN to compute base-10 logarithm
    FROM "TCGA_HG19_DATA_V0"."TCGA_HG19_DATA_V0"."RNASEQ_GENE_EXPRESSION_UNC_RSEM" expr
    JOIN "TCGA_HG19_DATA_V0"."TCGA_HG19_DATA_V0"."SOMATIC_MUTATION_MC3" mut
    ON expr."case_barcode" = mut."case_barcode"
    WHERE expr."HGNC_gene_symbol" = 'TP53' 
        AND expr."project_short_name" = 'TCGA-BRCA' 
        AND mut."project_short_name" = 'TCGA-BRCA'
        AND expr."normalized_count" > 0
),
Stats AS (
    -- Calculate group statistics and overall statistics
    SELECT 
        COUNT(*) AS "total_samples",                 -- Total number of samples
        COUNT(DISTINCT "Variant_Classification") AS "mutation_types",  -- Number of mutation types
        AVG("log10_expression") AS "grand_mean"     -- Grand mean of log10-transformed expression
    FROM ExpressionMutationData
),
GroupStats AS (
    -- Calculate group-specific means and related statistics
    SELECT 
        "Variant_Classification",
        COUNT(*) AS "n_j",                          -- Number of samples in each group
        AVG("log10_expression") AS "group_mean"     -- Mean expression in each group
    FROM ExpressionMutationData
    GROUP BY "Variant_Classification"
),
SSB AS (
    -- Compute Sum of Squares Between Groups (SSB)
    SELECT 
        SUM("n_j" * POWER("group_mean" - stats."grand_mean", 2)) AS "SSB" 
    FROM GroupStats
    CROSS JOIN Stats
),
SSW AS (
    -- Compute Sum of Squares Within Groups (SSW)
    SELECT 
        SUM(POWER(ed."log10_expression" - gs."group_mean", 2)) AS "SSW" 
    FROM ExpressionMutationData ed
    JOIN GroupStats gs
    ON ed."Variant_Classification" = gs."Variant_Classification"
),
ANOVA AS (
    -- Calculate Mean Squares and F-Statistic
    SELECT 
        stats."total_samples",
        stats."mutation_types",
        ssb."SSB",
        ssw."SSW",
        (ssb."SSB" / (stats."mutation_types" - 1)) AS "MSB",  -- Mean Square Between
        (ssw."SSW" / (stats."total_samples" - stats."mutation_types")) AS "MSW",  -- Mean Square Within
        ((ssb."SSB" / (stats."mutation_types" - 1)) / (ssw."SSW" / (stats."total_samples" - stats."mutation_types"))) AS "F_statistic"  -- F-Statistic
    FROM Stats stats
    CROSS JOIN SSB ssb
    CROSS JOIN SSW ssw
)
SELECT 
    "total_samples",
    "mutation_types",
    "MSB",
    "MSW",
    "F_statistic"
FROM ANOVA;