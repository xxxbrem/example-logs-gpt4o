SELECT 
    c."histological_type",
    COUNT(DISTINCT m."ParticipantBarcode") AS "mutated_patients",
    COUNT(DISTINCT c."bcr_patient_barcode") AS "total_patients",
    (COUNT(DISTINCT m."ParticipantBarcode")::FLOAT / COUNT(DISTINCT c."bcr_patient_barcode") * 100) AS "mutation_percentage"
FROM 
    PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED c
JOIN 
    PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE m
ON 
    c."bcr_patient_barcode" = m."ParticipantBarcode"
WHERE 
    m."Hugo_Symbol" = 'CDH1' AND c."acronym" = 'BRCA'
GROUP BY 
    c."histological_type"
HAVING 
    COUNT(DISTINCT m."ParticipantBarcode") > 0
ORDER BY 
    "mutation_percentage" DESC NULLS LAST
LIMIT 5;