SELECT TOP 5 clinic."histological_type", 
       COUNT(mc3."Hugo_Symbol") * 100.0 / COUNT(DISTINCT clinic."bcr_patient_barcode") AS "mutation_percentage"
FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED clinic
LEFT JOIN PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE mc3
ON clinic."bcr_patient_barcode" = mc3."ParticipantBarcode" 
   AND mc3."Hugo_Symbol" = 'CDH1'
WHERE clinic."acronym" = 'BRCA'
GROUP BY clinic."histological_type"
ORDER BY "mutation_percentage" DESC NULLS LAST;