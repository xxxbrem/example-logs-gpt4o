WITH MutationCount AS (
    SELECT 
        c."histological_type", 
        COUNT(DISTINCT c."bcr_patient_barcode") AS "Mutated_Patient_Count"
    FROM 
        "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" c
    JOIN 
        "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" m
    ON 
        c."bcr_patient_barcode" = m."ParticipantBarcode"
    WHERE 
        c."acronym" = 'BRCA' AND m."Hugo_Symbol" = 'CDH1'
    GROUP BY 
        c."histological_type"
),
TotalCount AS (
    SELECT 
        "histological_type", 
        COUNT(DISTINCT "bcr_patient_barcode") AS "Total_Patient_Count"
    FROM 
        "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED"
    WHERE 
        "acronym" = 'BRCA'
    GROUP BY 
        "histological_type"
)
SELECT 
    t."histological_type", 
    m."Mutated_Patient_Count", 
    t."Total_Patient_Count", 
    (m."Mutated_Patient_Count" * 100.0 / t."Total_Patient_Count") AS "Mutation_Percentage"
FROM 
    MutationCount m
JOIN 
    TotalCount t
ON 
    m."histological_type" = t."histological_type"
ORDER BY 
    "Mutation_Percentage" DESC NULLS LAST
LIMIT 5;