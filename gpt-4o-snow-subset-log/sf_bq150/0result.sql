WITH log_transformed_expression AS (
    SELECT 
        m."Variant_Classification",
        LN(NULLIF(e."normalized_count", 0)) / LN(10) AS "log_expression"
    FROM TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.RNASEQ_GENE_EXPRESSION_UNC_RSEM e
    JOIN TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.SOMATIC_MUTATION_MC3 m
        ON e."case_barcode" = m."case_barcode"
    WHERE e."HGNC_gene_symbol" = 'TP53' AND m."Hugo_Symbol" = 'TP53'
),
group_stats AS (
    SELECT 
        "Variant_Classification",
        COUNT(*) AS "sample_count",
        AVG("log_expression") AS "mean_log_expression"
    FROM log_transformed_expression
    GROUP BY "Variant_Classification"
),
grand_stats AS (
    SELECT 
        AVG("log_expression") AS "grand_mean",
        COUNT(*) AS "total_samples",
        (SELECT COUNT(DISTINCT "Variant_Classification") FROM log_transformed_expression) AS "mutation_types"
    FROM log_transformed_expression
),
ssb AS (
    SELECT 
        SUM(g."sample_count" * POWER(g."mean_log_expression" - gs."grand_mean", 2)) AS "SSB"
    FROM group_stats g, grand_stats gs
),
ssw AS (
    SELECT 
        SUM(POWER(l."log_expression" - g."mean_log_expression", 2)) AS "SSW"
    FROM log_transformed_expression l
    JOIN group_stats g 
        ON l."Variant_Classification" = g."Variant_Classification"
),
anova_results AS (
    SELECT 
        gs."total_samples",
        gs."mutation_types",
        (gs."mutation_types" - 1) AS "df_between",
        (gs."total_samples" - gs."mutation_types") AS "df_within",
        sb."SSB",
        sw."SSW",
        sb."SSB" / (gs."mutation_types" - 1) AS "MSB",
        sw."SSW" / (gs."total_samples" - gs."mutation_types") AS "MSW",
        (sb."SSB" / (gs."mutation_types" - 1)) / (sw."SSW" / (gs."total_samples" - gs."mutation_types")) AS "F_statistic"
    FROM grand_stats gs, ssb sb, ssw sw
)
SELECT 
    "total_samples",
    "mutation_types",
    "MSB",
    "MSW",
    "F_statistic"
FROM anova_results;