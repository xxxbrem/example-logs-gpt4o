WITH FilteredData AS (
    SELECT 
        c."histological_type",
        CASE 
            WHEN m."Hugo_Symbol" = 'CDH1' AND m."FILTER" = 'PASS' THEN 1 
            ELSE 0 
        END AS "CDH1_Mutation_Presence",
        CASE 
            WHEN m."Hugo_Symbol" != 'CDH1' OR m."Hugo_Symbol" IS NULL THEN 1 
            ELSE 0 
        END AS "No_CDH1_Mutation"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED c
    LEFT JOIN PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE m
    ON c."bcr_patient_barcode" = m."ParticipantBarcode"
    WHERE c."acronym" = 'BRCA' AND c."histological_type" IS NOT NULL AND (m."FILTER" = 'PASS' OR m."FILTER" IS NULL)
),
AggregatedData AS (
    SELECT 
        "histological_type",
        SUM("CDH1_Mutation_Presence") AS "CDH1_Mutations",
        SUM("No_CDH1_Mutation") AS "No_CDH1_Mutations",
        (SUM("CDH1_Mutation_Presence") + SUM("No_CDH1_Mutation")) AS "Total"
    FROM FilteredData
    GROUP BY "histological_type"
),
FilteredAggregates AS (
    SELECT 
        "histological_type",
        "CDH1_Mutations",
        "No_CDH1_Mutations"
    FROM AggregatedData
    WHERE "Total" > 10 -- Exclude histological types or mutation statuses with marginal totals <= 10
)
-- Final aggregated data for chi-square input
SELECT 
    "histological_type",
    "CDH1_Mutations",
    "No_CDH1_Mutations"
FROM FilteredAggregates;