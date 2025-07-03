SELECT 
    clinical."histological_type" AS "Histological_Type",
    COUNT(CASE WHEN mutation."Hugo_Symbol" = 'CDH1' THEN 1 END) AS "CDH1_Present",
    COUNT(CASE WHEN mutation."Hugo_Symbol" IS NULL THEN 1 END) AS "CDH1_Absent"
FROM 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" clinical
LEFT JOIN 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" mutation
ON 
    clinical."bcr_patient_barcode" = mutation."ParticipantBarcode"
WHERE 
    clinical."acronym" = 'BRCA' 
    AND clinical."histological_type" IS NOT NULL
GROUP BY 
    clinical."histological_type"
HAVING 
    COUNT(*) > 10
ORDER BY 
    clinical."histological_type";