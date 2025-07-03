WITH ClinicalData AS (
    SELECT 
        "bcr_patient_barcode", 
        "histological_type", 
        "acronym"
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
    WHERE 
        "acronym" = 'BRCA' AND 
        "histological_type" IS NOT NULL
),
MutationData AS (
    SELECT 
        "ParticipantBarcode", 
        "Hugo_Symbol", 
        "FILTER" 
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE
    WHERE 
        "Hugo_Symbol" = 'CDH1' AND 
        "FILTER" = 'PASS' AND 
        "Study" = 'BRCA'
),
FilteredData AS (
    SELECT 
        C."bcr_patient_barcode",
        C."histological_type",
        M."FILTER"
    FROM 
        ClinicalData C
    LEFT JOIN 
        MutationData M
    ON 
        C."bcr_patient_barcode" = M."ParticipantBarcode"
),
ContingencyTable AS (
    SELECT 
        "histological_type",
        COUNT(CASE WHEN "FILTER" = 'PASS' THEN 1 END) AS Mutation_Present,
        COUNT(CASE WHEN "FILTER" IS NULL THEN 1 END) AS Mutation_Absent
    FROM 
        FilteredData
    GROUP BY 
        "histological_type"
),
FilteredContingencyTable AS (
    SELECT *
    FROM ContingencyTable
    WHERE 
        (Mutation_Present + Mutation_Absent) > 10
)
SELECT 
    *,
    ((
        ((Mutation_Present * Mutation_Absent) * (Mutation_Present + Mutation_Absent)) / GREATEST(SUM(Mutation_Present + Mutation_Absent) OVER (), 1)
    )) AS ChiSquareValue
FROM 
    FilteredContingencyTable;