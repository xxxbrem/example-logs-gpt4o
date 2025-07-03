SELECT c."histological_type", 
       COUNT(DISTINCT m."ParticipantBarcode") * 100.0 / COUNT(DISTINCT c."bcr_patient_barcode") AS "Mutation_Percentage"
FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" c
LEFT JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" m
ON c."bcr_patient_barcode" = m."ParticipantBarcode" AND m."Hugo_Symbol" = 'CDH1' AND m."Study" = 'BRCA'
WHERE c."acronym" = 'BRCA'
GROUP BY c."histological_type"
ORDER BY "Mutation_Percentage" DESC NULLS LAST
LIMIT 5;