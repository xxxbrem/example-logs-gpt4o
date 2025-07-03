SELECT 
    c."icd_o_3_histology", 
    AVG(p."log_expression") AS "avg_log_expression"
FROM (
    SELECT 
        g."ParticipantBarcode", 
        LN(AVG(g."normalized_count") + 1) / LN(10) AS "log_expression"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED g
    WHERE g."Symbol" = 'IGF2' 
      AND g."normalized_count" > 0
    GROUP BY g."ParticipantBarcode"
) p
JOIN PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED c
  ON p."ParticipantBarcode" = c."bcr_patient_barcode"
WHERE c."acronym" = 'LGG' 
  AND c."icd_o_3_histology" NOT ILIKE '%[%]%'
GROUP BY c."icd_o_3_histology"
LIMIT 20;