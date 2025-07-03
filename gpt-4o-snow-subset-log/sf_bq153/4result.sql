WITH FilteredClinicalData AS (
    SELECT DISTINCT 
        "bcr_patient_barcode", 
        "icd_o_3_histology"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
    WHERE "acronym" = 'LGG' AND "icd_o_3_histology" NOT LIKE '[%'
),
FilteredGeneExpression AS (
    SELECT 
        "ParticipantBarcode", 
        "normalized_count"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED
    WHERE "Symbol" = 'IGF2'
),
JoinedData AS (
    SELECT 
        c."icd_o_3_histology", 
        g."ParticipantBarcode", 
        LN(g."normalized_count" + 1) / LN(10) AS "log10_normalized_count"
    FROM FilteredGeneExpression g
    JOIN FilteredClinicalData c
    ON g."ParticipantBarcode" = c."bcr_patient_barcode"
)
SELECT 
    "icd_o_3_histology", 
    AVG("log10_normalized_count") AS "avg_log10_expression"
FROM JoinedData
GROUP BY "icd_o_3_histology"
ORDER BY "icd_o_3_histology";