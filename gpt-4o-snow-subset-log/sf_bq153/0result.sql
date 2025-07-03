WITH ValidClinicalData AS (
    SELECT 
        "bcr_patient_barcode", 
        "patient_id",
        "icd_o_3_histology" 
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
    WHERE 
        "acronym" = 'LGG' 
        AND "icd_o_3_histology" NOT LIKE '[%'
),
GeneExpressionData AS (
    SELECT 
        "ParticipantBarcode", 
        "normalized_count" 
    FROM 
        PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED
    WHERE 
        "Symbol" = 'IGF2'
),
JoinedData AS (
    SELECT 
        c."icd_o_3_histology", 
        g."normalized_count"
    FROM 
        ValidClinicalData c
    INNER JOIN 
        GeneExpressionData g
    ON 
        c."bcr_patient_barcode" = g."ParticipantBarcode"
),
LogTransformedData AS (
    SELECT 
        "icd_o_3_histology", 
        LN("normalized_count" + 1) / LN(10) AS log_expr
    FROM 
        JoinedData
),
AveragePerHistology AS (
    SELECT 
        "icd_o_3_histology", 
        AVG(log_expr) AS avg_log_expr
    FROM 
        LogTransformedData
    GROUP BY 
        "icd_o_3_histology"
)
SELECT 
    "icd_o_3_histology", 
    avg_log_expr
FROM 
    AveragePerHistology
ORDER BY 
    avg_log_expr DESC NULLS LAST;