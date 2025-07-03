WITH expression_data AS (
    SELECT 
        "case_barcode", 
        "normalized_count", 
        LN("normalized_count") / LN(10) AS "log10_expression"
    FROM 
        TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.RNASEQ_GENE_EXPRESSION_UNC_RSEM
    WHERE 
        "HGNC_gene_symbol" = 'TP53' 
        AND "project_short_name" = 'TCGA-BRCA'
        AND "normalized_count" > 0
),
mutation_data AS (
    SELECT DISTINCT 
        "case_barcode", 
        "Variant_Classification" 
    FROM 
        TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.SOMATIC_MUTATION_MC3
    WHERE 
        "Hugo_Symbol" = 'TP53' 
        AND "project_short_name" = 'TCGA-BRCA'
),
combined_data AS (
    SELECT 
        exp."log10_expression", 
        mut."Variant_Classification"
    FROM 
        expression_data exp
    JOIN 
        mutation_data mut
    ON 
        exp."case_barcode" = mut."case_barcode"
),
grp_stats AS (
    SELECT 
        "Variant_Classification", 
        COUNT(*) AS "group_count", 
        AVG("log10_expression") AS "group_mean"
    FROM 
        combined_data
    GROUP BY 
        "Variant_Classification"
),
overall_stats AS (
    SELECT 
        COUNT(*) AS "total_samples", 
        AVG("log10_expression") AS "grand_mean"
    FROM 
        combined_data
),
ssb AS (
    SELECT 
        SUM(gs."group_count" * POWER((gs."group_mean" - os."grand_mean"), 2)) AS "SSB"
    FROM 
        grp_stats gs, 
        overall_stats os
),
ssw AS (
    SELECT 
        SUM(POWER(cd."log10_expression" - gs."group_mean", 2)) AS "SSW"
    FROM 
        combined_data cd
    JOIN 
        grp_stats gs
    ON 
        cd."Variant_Classification" = gs."Variant_Classification"
),
anova_stats AS (
    SELECT 
        os."total_samples" AS "total_samples",
        (SELECT COUNT(*) FROM grp_stats) AS "num_groups",
        (SELECT "SSB" FROM ssb) AS "SSB",
        (SELECT "SSW" FROM ssw) AS "SSW",
        (SELECT "SSB" FROM ssb) / ( (SELECT COUNT(*) FROM grp_stats) - 1 ) AS "MSB",
        (SELECT "SSW" FROM ssw) / ( os."total_samples" - (SELECT COUNT(*) FROM grp_stats) ) AS "MSW"
    FROM 
        overall_stats os
)
SELECT 
    "total_samples",
    "num_groups",
    "MSB",
    "MSW",
    "MSB" / "MSW" AS "F_statistic"
FROM 
    anova_stats;