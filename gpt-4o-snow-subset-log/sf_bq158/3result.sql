SELECT c."histological_type", 
       COUNT(v."Hugo_Symbol") * 100.0 / COUNT(DISTINCT c."bcr_patient_barcode") AS "mutation_percentage"
FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED c 
LEFT JOIN PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE v 
ON c."bcr_patient_barcode" = v."ParticipantBarcode" 
WHERE c."acronym" = 'BRCA' AND (v."Hugo_Symbol" = 'CDH1' OR v."Hugo_Symbol" IS NULL) 
GROUP BY c."histological_type"
ORDER BY "mutation_percentage" DESC NULLS LAST
LIMIT 5;