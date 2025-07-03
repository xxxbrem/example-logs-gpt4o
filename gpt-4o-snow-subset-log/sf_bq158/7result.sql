SELECT TOP 5 
    clin."histological_type", 
    COUNT(mut."ParticipantBarcode") * 100.0 / COUNT(DISTINCT clin."bcr_patient_barcode") AS "Mutation_Percentage"
FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" AS mut
INNER JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" AS clin
ON mut."ParticipantBarcode" = clin."bcr_patient_barcode"
WHERE mut."Study" = 'BRCA' AND mut."Hugo_Symbol" = 'CDH1'
GROUP BY clin."histological_type"
ORDER BY "Mutation_Percentage" DESC NULLS LAST;