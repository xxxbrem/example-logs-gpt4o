WITH ExpressionMutationData AS (
    SELECT 
        e."case_barcode",
        LN(e."normalized_count") / LN(10) AS "log_expression", -- Using natural log (LN) to replace LOG10
        m."Variant_Classification"
    FROM TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.RNASEQ_GENE_EXPRESSION_UNC_RSEM e
    JOIN TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.SOMATIC_MUTATION_MC3 m
        ON e."case_barcode" = m."case_barcode"
    WHERE 
        e."HGNC_gene_symbol" = 'TP53' 
        AND e."project_short_name" = 'TCGA-BRCA'
        AND m."Hugo_Symbol" = 'TP53'
),
GroupStats AS (
    SELECT 
        "Variant_Classification",
        COUNT(*) AS "group_count",
        AVG("log_expression") AS "group_mean"
    FROM ExpressionMutationData
    GROUP BY "Variant_Classification"
),
OverallStats AS (
    SELECT 
        COUNT(*) AS "total_samples",
        COUNT(DISTINCT "Variant_Classification") AS "mutation_types",
        AVG("log_expression") AS "grand_mean"
    FROM ExpressionMutationData
),
SSB AS (
    SELECT 
        SUM(gs."group_count" * POWER(gs."group_mean" - os."grand_mean", 2)) AS "SSB"
    FROM GroupStats gs, OverallStats os
),
SSW AS (
    SELECT 
        SUM(POWER(em."log_expression" - gs."group_mean", 2)) AS "SSW"
    FROM ExpressionMutationData em
    JOIN GroupStats gs
        ON em."Variant_Classification" = gs."Variant_Classification"
),
DegreesOfFreedom AS (
    SELECT 
        (os."mutation_types" - 1) AS "df_between",
        (os."total_samples" - os."mutation_types") AS "df_within"
    FROM OverallStats os
),
MeanSquares AS (
    SELECT 
        ssb."SSB" / df."df_between" AS "MSB",
        ssw."SSW" / df."df_within" AS "MSW"
    FROM SSB ssb, SSW ssw, DegreesOfFreedom df
),
FStatistic AS (
    SELECT 
        ms."MSB" / ms."MSW" AS "F_statistic"
    FROM MeanSquares ms
)
SELECT 
    os."total_samples",
    os."mutation_types",
    ms."MSB" AS "mean_square_between",
    ms."MSW" AS "mean_square_within",
    f."F_statistic"
FROM OverallStats os
CROSS JOIN MeanSquares ms
CROSS JOIN FStatistic f;