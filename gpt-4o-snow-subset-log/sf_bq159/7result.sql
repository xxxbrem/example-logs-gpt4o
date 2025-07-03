WITH ClinicalFiltered AS (
    SELECT 
        "bcr_patient_barcode", 
        "histological_type"
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
    WHERE 
        "acronym" = 'BRCA' 
        AND "histological_type" IS NOT NULL
),
MutationFiltered AS (
    SELECT 
        "ParticipantBarcode", 
        'Mutation_Present' AS "CDH1_Mutation_Status"
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE
    WHERE 
        "Study" = 'BRCA' 
        AND "Hugo_Symbol" = 'CDH1' 
        AND "FILTER" = 'PASS'
    GROUP BY 
        "ParticipantBarcode"
),
ClinicalWithMutation AS (
    SELECT 
        c."bcr_patient_barcode", 
        c."histological_type", 
        COALESCE(m."CDH1_Mutation_Status", 'No_Mutation') AS "CDH1_Mutation_Status"
    FROM 
        ClinicalFiltered c
    LEFT JOIN 
        MutationFiltered m
    ON 
        c."bcr_patient_barcode" = m."ParticipantBarcode"
),
CountsByGroup AS (
    SELECT 
        "histological_type", 
        "CDH1_Mutation_Status", 
        COUNT(*) AS "count"
    FROM 
        ClinicalWithMutation
    GROUP BY 
        "histological_type", 
        "CDH1_Mutation_Status"
),
ValidHistologicalTypes AS (
    SELECT 
        "histological_type"
    FROM 
        CountsByGroup
    GROUP BY 
        "histological_type"
    HAVING 
        SUM("count") > 10
),
ValidMutationStatuses AS (
    SELECT 
        "CDH1_Mutation_Status"
    FROM 
        CountsByGroup
    GROUP BY 
        "CDH1_Mutation_Status"
    HAVING 
        SUM("count") > 10
)
SELECT 
    cbg."histological_type", 
    cbg."CDH1_Mutation_Status", 
    cbg."count"
FROM 
    CountsByGroup cbg
WHERE 
    cbg."histological_type" IN (
        SELECT "histological_type" FROM ValidHistologicalTypes
    )
    AND cbg."CDH1_Mutation_Status" IN (
        SELECT "CDH1_Mutation_Status" FROM ValidMutationStatuses
    );