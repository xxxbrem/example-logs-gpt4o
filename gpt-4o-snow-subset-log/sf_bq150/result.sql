WITH LogTransformedExpression AS (
    -- Step 1: Retrieve log10-transformed expression data for TP53 in TCGA-BRCA samples
    SELECT 
        r."case_barcode",
        LN(r."normalized_count") / LN(10) AS "log_expression", -- Use LN(x)/LN(10) to calculate log10
        m."Variant_Classification"
    FROM TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.RNASEQ_GENE_EXPRESSION_UNC_RSEM r
    JOIN TCGA_HG19_DATA_V0.TCGA_HG19_DATA_V0.SOMATIC_MUTATION_MC3 m
      ON r."case_barcode" = m."case_barcode"
    WHERE r."project_short_name" = 'TCGA-BRCA'
      AND r."HGNC_gene_symbol" = 'TP53'
      AND m."Hugo_Symbol" = 'TP53'
      AND r."normalized_count" > 0
),
GroupAggregates AS (
    -- Step 2: Calculate group means, group sizes, and grand mean
    SELECT 
        "Variant_Classification",
        COUNT(*) AS "n_j",
        AVG("log_expression") AS "group_mean"
    FROM LogTransformedExpression
    GROUP BY "Variant_Classification"
),
GrandStats AS (
    -- Step 3: Calculate total number of samples (N) and grand mean
    SELECT 
        COUNT(*) AS "N",
        AVG("log_expression") AS "grand_mean"
    FROM LogTransformedExpression
),
BetweenGroupStats AS (
    -- Step 4: Compute Sum of Squares Between (SSB)
    SELECT 
        SUM(g."n_j" * POWER(g."group_mean" - gs."grand_mean", 2)) AS "SSB",
        gs."grand_mean",
        gs."N",
        COUNT(*) AS "k"  -- Total number of mutation types
    FROM GroupAggregates g, GrandStats gs
    GROUP BY gs."grand_mean", gs."N"
),
WithinGroupStats AS (
    -- Step 5: Compute Sum of Squares Within (SSW)
    SELECT 
        SUM(POWER(le."log_expression" - g."group_mean", 2)) AS "SSW"
    FROM LogTransformedExpression le
    JOIN GroupAggregates g
      ON le."Variant_Classification" = g."Variant_Classification"
),
ANOVAResults AS (
    -- Step 6: Compute Mean Squares and the F-statistic
    SELECT 
        bgs."SSB",
        wgs."SSW",
        (bgs."k" - 1) AS "df_between",
        (bgs."N" - bgs."k") AS "df_within",
        (bgs."SSB" / (bgs."k" - 1)) AS "MSB",
        (wgs."SSW" / (bgs."N" - bgs."k")) AS "MSW",
        ((bgs."SSB" / (bgs."k" - 1)) / (wgs."SSW" / (bgs."N" - bgs."k"))) AS "F_statistic",
        bgs."N" AS "total_samples",
        bgs."k" AS "mutation_types"
    FROM BetweenGroupStats bgs
    CROSS JOIN WithinGroupStats wgs
)
-- Step 7: Return relevant ANOVA results
SELECT 
    "total_samples", 
    "mutation_types", 
    "MSB" AS "mean_square_between", 
    "MSW" AS "mean_square_within", 
    "F_statistic"
FROM ANOVAResults;